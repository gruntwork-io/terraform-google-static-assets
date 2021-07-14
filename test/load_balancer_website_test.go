package test

import (
	"fmt"
	"net/http"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestLoadbalancerWebsites(t *testing.T) {
	t.Parallel()

	var testcases = []struct {
		testName     string
		createDomain bool
		enableSsl    bool
	}{
		{
			"TestLoadBalancerIpOnly",
			false,
			false,
		},
		{
			"TestLoadBalancerWithDomainAndSsl",
			true,
			true,
		},
	}

	for _, testCase := range testcases {
		// The following is necessary to make sure testCase's values don't
		// get updated due to concurrency within the scope of t.Run(..) below
		testCase := testCase

		t.Run(testCase.testName, func(t *testing.T) {
			t.Parallel()

			logger.Logf(t, "Starting test %s", testCase.testName)

			//os.Setenv("SKIP_bootstrap", "true")
			//os.Setenv("SKIP_deploy", "true")
			//os.Setenv("SKIP_web_tests", "true")
			//os.Setenv("SKIP_teardown", "true")

			_examplesDir := test_structure.CopyTerraformFolderToTemp(t, "../", "examples")
			exampleDir := filepath.Join(_examplesDir, EXAMPLE_NAME_LB_SITE)

			test_structure.RunTestStage(t, "bootstrap", func() {
				logger.Logf(t, "Bootstrapping variables")

				// Bucket names must be lowercase and start with a letter
				randomId := strings.ToLower(random.UniqueId())
				randomId = fmt.Sprintf("a%s", randomId)

				domainName := fmt.Sprintf("%s.%s", randomId, ROOT_DOMAIN_NAME_FOR_TEST)

				projectId := gcp.GetGoogleProjectIDFromEnvVar(t)

				test_structure.SaveString(t, exampleDir, KEY_DOMAIN_NAME, domainName)
				test_structure.SaveString(t, exampleDir, KEY_PROJECT, projectId)
			})

			// At the end of the test, run `terraform destroy` to clean up any resources that were created
			defer test_structure.RunTestStage(t, "teardown", func() {
				logger.Logf(t, "Tear down infrastructure")

				terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
				terraform.Destroy(t, terraformOptions)
			})

			test_structure.RunTestStage(t, "deploy", func() {
				logger.Logf(t, "Deploying the website")

				projectId := test_structure.LoadString(t, exampleDir, KEY_PROJECT)
				domainName := test_structure.LoadString(t, exampleDir, KEY_DOMAIN_NAME)

				terraformOptions := createTerratestOptionsForLoadBalancer(exampleDir, projectId, domainName, testCase.createDomain, testCase.enableSsl)

				test_structure.SaveTerraformOptions(t, exampleDir, terraformOptions)

				terraform.InitAndApply(t, terraformOptions)
			})

			test_structure.RunTestStage(t, "web_tests", func() {

				logger.Logf(t, "Running web tests by calling the created website")

				domainName := test_structure.LoadString(t, exampleDir, KEY_DOMAIN_NAME)

				// If we didn't create a custom domain, use the LB public IP to connect
				if !testCase.createDomain {
					terraformOptions := test_structure.LoadTerraformOptions(t, exampleDir)
					domainName = terraform.Output(t, terraformOptions, OUTPUT_LB_IP_ADDRESS)
				}

				expectedIndexBody := "Hello, World!"
				expectedNotFoundBody := "Uh oh"

				// Only run ssl tests if enabled
				if testCase.enableSsl {
					testWebsite(t, "https", domainName, "", http.StatusOK, expectedIndexBody)
					testWebsite(t, "https", domainName, "/bogus", http.StatusNotFound, expectedNotFoundBody)
				}

				// Plain HTTP always enabled, so run always
				testWebsite(t, "http", domainName, "", http.StatusOK, expectedIndexBody)
				testWebsite(t, "http", domainName, "/bogus", http.StatusNotFound, expectedNotFoundBody)
			})
		})
	}

}

func createTerratestOptionsForLoadBalancer(exampleDir string, projectId string, domainName string, createDnsEntry bool, enableSsl bool) *terraform.Options {

	terratestOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: exampleDir,
		Vars: map[string]interface{}{
			"project":                          projectId,
			"website_domain_name":              domainName,
			"create_dns_entry":                 createDnsEntry,
			"enable_ssl":                       enableSsl,
			"enable_http":                      true,
			"dns_managed_zone_name":            MANAGED_ZONE_NAME_FOR_TEST,
			"force_destroy_website":            "true",
			"force_destroy_access_logs_bucket": "true",
		},
	}

	return terratestOptions
}
