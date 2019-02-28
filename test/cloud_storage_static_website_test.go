package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
	"net/http"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

const ROOT_DOMAIN_NAME_FOR_TEST = "gcloud-dev.com"
const MANAGED_ZONE_NAME_FOR_TEST = "gclouddev"

const KEY_PROJECT = "project"
const KEY_DOMAIN_NAME = "domain-name"

const EXAMPLE_NAME_STATIC_SITE = "cloud-storage-static-website"

func TestCloudStorageStaticSite(t *testing.T) {
	t.SkipNow()

	t.Parallel()

	//os.Setenv("SKIP_bootstrap", "true")
	//os.Setenv("SKIP_deploy", "true")
	//os.Setenv("SKIP_web_tests", "true")
	//os.Setenv("SKIP_teardown", "true")

	_examplesDir := test_structure.CopyTerraformFolderToTemp(t, "../", "examples")
	exampleDir := filepath.Join(_examplesDir, EXAMPLE_NAME_STATIC_SITE)

	test_structure.RunTestStage(t, "bootstrap", func() {
		logger.Logf(t, "Bootstrapping variables")

		randomId := strings.ToLower(random.UniqueId())
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
		terraformOptions := createTerratestOptionsForStaticSite(exampleDir, projectId, domainName, MANAGED_ZONE_NAME_FOR_TEST)
		test_structure.SaveTerraformOptions(t, exampleDir, terraformOptions)

		terraform.InitAndApply(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "web_tests", func() {

		logger.Logf(t, "Running web tests by calling the created website")

		domainName := test_structure.LoadString(t, exampleDir, KEY_DOMAIN_NAME)

		expectedIndexBody := "Hello, World!"
		expectedNotFoundBody := "Uh oh"

		// Go seems to cache the DNS results quite heavily, so we'll add
		// a lot of time to survive that
		maxRetries := 20
		sleepBetweenRetries := 30 * time.Second

		testWebsite(t, "http", domainName, "", http.StatusOK, expectedIndexBody, maxRetries, sleepBetweenRetries)
		testWebsite(t, "http", domainName, "bogus", http.StatusNotFound, expectedNotFoundBody, maxRetries, sleepBetweenRetries)

	})
}

func createTerratestOptionsForStaticSite(exampleDir string, projectId string, domainName string, zoneName string) *terraform.Options {

	terratestOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: exampleDir,
		Vars: map[string]interface{}{
			"project":                          projectId,
			"website_domain_name":              domainName,
			"create_dns_entry":                 "true",
			"dns_managed_zone_name":            zoneName,
			"force_destroy_website":            "true",
			"force_destroy_access_logs_bucket": "true",
		},
	}

	return terratestOptions
}
