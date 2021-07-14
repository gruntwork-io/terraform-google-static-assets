package test

import (
	"fmt"
	"net/http"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/gcp"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestCloudStorageStaticSite(t *testing.T) {
	t.Parallel()

	//os.Setenv("SKIP_bootstrap", "true")
	//os.Setenv("SKIP_deploy", "true")
	//os.Setenv("SKIP_web_tests", "true")
	//os.Setenv("SKIP_teardown", "true")

	// The example is the root example
	exampleDir := test_structure.CopyTerraformFolderToTemp(t, "../", ".")

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

		// Test http with the configured domain name
		testWebsite(t, "http", domainName, "", http.StatusOK, expectedIndexBody)
		testWebsite(t, "http", domainName, "/bogus", http.StatusNotFound, expectedNotFoundBody)

		// Test that individual objects are accessible with HTTPS
		testWebsite(t, "https", "storage.googleapis.com", fmt.Sprintf("/%s/index.html", domainName), http.StatusOK, expectedIndexBody)
	})
}

func createTerratestOptionsForStaticSite(exampleDir string, projectId string, domainName string, zoneName string) *terraform.Options {

	terratestOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: exampleDir,
		Vars: map[string]interface{}{
			"project":                          projectId,
			"website_domain_name":              domainName,
			"create_dns_entry":                 true,
			"dns_managed_zone_name":            zoneName,
			"force_destroy_website":            true,
			"force_destroy_access_logs_bucket": true,
		},
	}

	return terratestOptions
}
