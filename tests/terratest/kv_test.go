package test

import (
	"path/filepath"
	"testing"

 	"github.com/gruntwork-io/terratest/modules/azure"
//  	kvauth "github.com/Azure/azure-sdk-for-go/services/keyvault/auth"
//     kvmng "github.com/Azure/azure-sdk-for-go/services/keyvault/mgmt/2016-10-01/keyvault"
//     "github.com/Azure/azure-sdk-for-go/services/keyvault/v7.0/keyvault"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// Testing the secure-file-transfer Module
func TestTerraformAzureKeyVault(t *testing.T) {
	t.Parallel()

	//subscriptionID := "e6b5053b-4c38-4475-a835-a025aeb3d8c7"
	// Terraform plan.out File Path
	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "example/")
	planFilePath := filepath.Join(exampleFolder, "plan.out")

	terraformPlanOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../example/",
		Upgrade:      true,

		// Variables to pass to our Terraform code using -var options
		VarFiles: []string{"kv_terratest.tfvars"},

		//Environment variables to set when running Terraform

		// Configure a plan file path so we can introspect the plan and make assertions about it.
		PlanFilePath: planFilePath,
	})

	// Run terraform init plan and show and fail the test if there are any errors
	terraform.InitAndPlanAndShowWithStruct(t, terraformPlanOptions)

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformPlanOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformPlanOptions)

	// Run `terraform output` to get the values of output variables
 	resourceGroupName := terraform.Output(t, terraformPlanOptions, "resource_group_name")
	kv_name := terraform.Output(t, terraformPlanOptions, "name")
 	kv_id := terraform.Output(t, terraformPlanOptions, "id")
 //	kv_secret := terraform.Output(t, terraformPlanOptions, "secrets.name")
//  	kv_uri := terraform.Output(t, terraformPlanOptions, "key_vault_uri")
 	subscriptionID := terraform.Output(t, terraformPlanOptions, "subscription_id")

   //  assert.True(t, azure.KeyVaultSecretExists(t, kv_name, kv_secret ))
    keyVault, _ := azure.GetKeyVaultE(t, resourceGroupName, kv_name, subscriptionID)

	assert.Equal(t, kv_id, *keyVault.ID)


}
