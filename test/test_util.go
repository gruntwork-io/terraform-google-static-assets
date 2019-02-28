package test

import (
	"context"
	"fmt"
	"github.com/go-errors/errors"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	"net"
	"net/http"
	"strings"
	"testing"
	"time"
)

func testWebsite(t *testing.T, protocol string, domainName string, path string, expectedStatusCode int, expectedBodyText string, maxRetries int, sleepBetweenRetries time.Duration) {

	url := fmt.Sprintf("%s://%s/%s", protocol, domainName, path)
	description := fmt.Sprintf("Making HTTP request to %s", url)

	port := "80"
	if strings.Contains(protocol, "https") {
		port = "443"
	}

	output, err := retry.DoWithRetryE(t, description, maxRetries, sleepBetweenRetries, func() (s string, e error) {

		logger.Logf(t, description)

		// Go default DNS resolving doesn't really do a great job
		// so we're using custom resolving
		ip, iperr := lookupIP(t, domainName)

		if iperr != nil {
			return "", iperr
		}

		address := fmt.Sprintf("%s:%s", ip, port)
		domainWithPort := fmt.Sprintf("%s:%s", domainName, port)

		// Create a basic dialer
		dialer := &net.Dialer{
			Timeout:   10 * time.Second,
			KeepAlive: 10 * time.Second,
			DualStack: true,
		}

		// We looked up the IP, let's inject it into the http dial context
		http.DefaultTransport.(*http.Transport).DialContext = func(ctx context.Context, network, addr string) (net.Conn, error) {
			if addr == domainWithPort {
				addr = address
			}
			return dialer.DialContext(ctx, network, addr)
		}

		resp, err := http.Get(url)
		if err != nil {
			return "", err
		}

		defer resp.Body.Close()
		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return "", err
		}

		if resp.StatusCode == expectedStatusCode {
			logger.Logf(t, "Got expected status code %d from URL %s", expectedStatusCode, url)
			return string(body), nil
		} else {
			return "", fmt.Errorf("Expected status code %d but got %d from URL %s", expectedStatusCode, resp.StatusCode, url)
		}

	})

	assert.NoError(t, err, "Failed to call URL %s", url)

	if strings.Contains(output, expectedBodyText) {
		logger.Logf(t, "URL %s contained expected text %s!", url, expectedBodyText)
	} else {
		t.Fatalf("URL %s did not contain expected text %s. Instead, it returned:\n%s", url, expectedBodyText, output)
	}
}

func lookupIP(t *testing.T, domainName string) (string, error) {
	description := fmt.Sprintf("Resolving domain %s", domainName)

	// Go default DNS resolving doesn't really do a great job
	// So... we're creating a custom resolver to query Google DNS directly
	// Which is OK, as we're creating the site in GCP, after all
	r := net.Resolver{
		PreferGo: true,
		Dial:     GoogleDNSDialer,
	}
	ctx := context.Background()

	logger.Logf(t, description)

	ips, err := r.LookupIPAddr(ctx, domainName)
	if err != nil {
		logger.Logf(t, "Could not get IPs: %v\n", err)
		return "", err
	}

	for _, ip := range ips {
		logger.Logf(t, "Got IP %s", ip.String())
		if strings.Contains(ip.String(), ".") {
			return ip.String(), nil
		}
	}

	return "", errors.New("Could not find IPV4 address")

}

func GoogleDNSDialer(ctx context.Context, network, address string) (net.Conn, error) {
	d := net.Dialer{}
	if network == "udp" {
		return d.DialContext(ctx, "udp", "8.8.8.8:53")
	}
	return d.DialContext(ctx, network, address)
}
