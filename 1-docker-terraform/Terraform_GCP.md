

<hr>

<div align="center">
    
# TERRAFORM and GCP 
(*for Linux*)
<hr />

[GCP ACCOUNT SETUP](#gcp-account-setup) •
[TERRAFORM MAIN.TF](#terraform-maintf) •
[RESOURCES](#resources) •
[MANAGE RESOURCES](#manage-resources) •
[USING VARIABLES](#using-variables)
</div>

<hr />
<br>

[Boilerplate Terraform .gitignore](https://spacelift.io/blog/terraform-gitignore) <br>

HashiCorp terraform is an infrastructure as code (IaC) tool that lets you define both on-prem and cloud resources in human-readable config files that you can version, reuse, and share. You can then use a consistent workflow to provision and manage all of your infrastructure throughout its lifecycle. [Source](https://developer.hashicorp.com/terraform/intro)
<br><br>

**ADVANTAGES** 
- You can provision infrastructure resources (VMs, containers, storage etc.) with declarative configuration files instead of a GUI
- Supports developer best practices for change management
- Simple to keep track of and manage infrastructure
- You can create, deploy, and destroy an entire cluster of resources together
- Easy to ensure resources are removed
- Easy to collaborate
- Reproducible
<br><br>

**DOES NOT** 
- Manage code
- Change immutable resources (e.g., machine type, location)
- Manage resources not defined in the Terraform file
<br><br>

**KEY TERRAFORM COMMANDS** 
- `init` get the provider based on selected resources
- `plan` once you define the resources, shows what you are about to do
- `apply` do what is in the .tf files
- `destroy` bring down all that is in the .tf file
<br><br>

**REQUIREMENTS**  
1. Terraform Client
2. GCP Account
3. Google SDK - so that you can interact with the VMs from your command line
<br><br>

## GCP ACCOUNT SETUP 
1. Create an account with your Google email ID
2. Grant permissions to the APIs
3. Set up a project
4. Set up a service account and authentication

### SERVICE ACCOUNT AND AUTHENTICATION   
After you have created a GCP account and project and enabled the apis, you'll need to set up a GCP service account for Terraform. 

Service account:
   - similar to a user account that is used by particular services rather than by a user
   - will be used to by software to run tasks, run programs, access services (~make API calls) etc
   - has restricted/ limited permissions

#### ADD SERVICE ACCOUNT 
1. Go to ```I am and Admin > Service Accounts``` in the left hand nav. 
2. Click ```+ CREATE SERVICE ACCOUNT```
3. Enter a name and click ```CREATE & CONTINUE```
<img src="https://github.com/inner-outer-space/de-zoomcamp-2024/assets/12296455/7b0262a1-6cda-47a1-9f42-80d7eb1a338a" width="200" height="180">
   
#### GRANT PERMISIONS 
1. Add Permissions<br> 
For simplicity, we will grant broad admin permissions to this service account. Admin permissions include broad roles that permit numerous actions. With Terraform, our scope is limited to resource provisioning and de-provisioning, so a role with bucket creation and deletion capabilities would suffice. Similarly, for BigQuery, we only need the ability to create and delete datasets. In the real world, you would set up a custom service account for each service, giving it permissions only for the specific tasks it needs to perform. Add the following: <br>

   - Cloud Storage > Storage Admin  					*Grants full control of buckets and objects*<br>
   - Big Query > Big Query Admin					*Administer all BigQuery resources and data*<br>
   - Compute Engine > Compute Admin					*Full control of all Compute Engine resources.*

2. Modify Permissions
   - Go to `IAM` in the left hand nav<br>
   - Click on `Edit Principal` icon<br>
<p align="left">
	<img src="https://github.com/inner-outer-space/de-zoomcamp-2024/assets/12296455/0ff3ee7a-0361-4ee6-9ff2-a3124f5b9942" width="100" height="100">
</p>

#### AUTHORIZATION KEY
The GCP service account key is a JSON or P12 file that contains the credentials for a service account. It can be used to authenticate GCP service accounts used for managing GCP resources and interacting with GCP APIs. 

1. **Create and download key**<br>
   - On the Service Accounts page under the Actions ellipse, click `Manage Keys`
   - Click Add Key > Create new  and select JSON
   - The JSON file will be saved to your computer
<p align="center">
	
<div align="center">
<h3>
!!!BE VERY CAREFUL WITH YOUR CREDENTIALS!!! 
</h3>
</div>
<br>

 2. **Add Key to GCP environment variables**<br>
    - Move the downloaded JSON into the folder where you keep your GCP key
    - Add the file to your GCP environment variable. 
 
 `GOOGLE_APPLICATION_CREDENTIALS` is an environmental variable used by Google Cloud SDK and various Google Cloud services to specify the path to a key
 ```cli
 #Add for current session only
 export GOOGLE_APPLICATION_CREDENTIALS="path_to_file/file.json"

 
 #Persist by adding to .bashrc. Use `source ~/.bashrc` to see the change without a restart. 
 echo export GOOGLE_APPLICATION_CREDENTIALS="path_to_file/file.json" >> ~/.bashrc 
 ```
3. **Authentication**<br>
This command will authenticate using the environmental variable set in the last step.
##### You'll get a pop up asking you to verify --> verification refreshes the token. 
``` cli
gcloud auth application-default login
```
<br><br>

## TERRAFORM MAIN.TF 
```terraform fmt``` fixes the formatting of the tf file in the folder you run this command. 

**GCP PROVIDER BLOCK** <br> 
Define the provider in the main.tf file.  
1. Go to the Hashicorp [Google Cloud Platform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs) page
2. Click on `Use Provider`
3. Copy the provider blocks to your main.tf file
<br>

```terraform
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.11.0"
    }
  }
}

provider "google" {
  # Configuration options
}
```
<br>

**CONFIGURE THE PROJECT** 
<br> 
To connect to a Google Cloud project, add the following configuration options to the "google" provider block:


```terraform
provider "google" {
  credentials = <path_to_file/file.json>	# This method is NOT RECOMMENDED  
  project = "<your_project_id>"  		# Replace with your Google Cloud project ID on GCP Dashboard
  region  = "europe-west1"       		# Set your desired region
}
```
<br>

**INITIALIZE THE PROJECT** `Terraform init` 
<br> 
The terraform init command initializes a working directory containing configuration files and installs plugins for required providers. In this case,  Terraform will retrieve the google provider, which is the piece of code that connects us to talk to GCP. 
<br>
RUN Creates/ Downloads:  
- .terraform folder - created in the project directory and contains subdirectories and files related to initialization and plug in management.   
- .terraform.lock.hcl folder - lock file that records a list of provider plugins and their versions as hashes. 
<br><br>

## RESOURCES 
- BUCKETS - Cloud Storage - GCP containers that can store various types of data as flat files
- DATASETS - Big Query - structured data storage
<br>

**GCP BUCKET**
<br> 
[**Terraform google_storage_bucket Documentation**](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)
 
```terraform
resource "google_storage_bucket" "taxi-bucket" {
  name          = "aerobic-badge-408610-taxi-bucket"
  location      = "EU"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}
```
- `resource` \<resource being created\> \<local variable name\>  --> these names combined with a dot can be used to reference this resource in other blocks in this file (e.g., google_storage_bucket.taxi-bucket
- `name` this has to be globally unique across all of GCP to be unique. Using a variation on the project generally works. 
- `age` - in days 
<br>

**GCP DATASET** 
<br>
[**Terraform google_bigquerry_dataset Documentation**](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset)
```terraform
resource "google_bigquery_dataset" "taxi-dataset" {
  dataset_id = "taxi_dataset"
  location   = "EU"
}
```

## MANAGE RESOURCES
<br>

**TERRAFORM PLAN** 
<br>
Running `terraform plan` will show you the actions that will be taken and the details. 
```cli
Terraform will perform the following actions:

  # google_storage_bucket.taxi-bucket will be created
  + resource "google_storage_bucket" "taxi-bucket" {
      + effective_labels            = (known after apply)
      + force_destroy               = true
      + id                          = (known after apply)
      + location                    = "EU"
      + name                        = "aerobic-badge-408610-taxi-bucket"
      + project                     = (known after apply)
      + public_access_prevention    = (known after apply)
      + rpo                         = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + terraform_labels            = (known after apply)
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)
      + lifecycle_rule {
          + action {
              + type = "AbortIncompleteMultipartUpload"
            }
          + condition {
              + age                   = 1
              + matches_prefix        = []
              + matches_storage_class = []
              + matches_suffix        = []
              + with_state            = (known after apply)
            }
        }
    }
```
<br><br>

**TERRAFORM APPLY** 
<br>
Running `terraform apply` executes the plan proposed in terraform plan. In this example it will add a bucket to this project and creates a terraform.tfstate file. This state file keeps track of resources created by your configuration and maps them to real-world resources

The bucket can be seen at `Cloud Storage > Buckets` in the left hand nav. <br>
![image](https://github.com/inner-outer-space/de-zoomcamp-2024/assets/12296455/ab621b97-6048-4624-ad21-1379cbf76a4b)

The dataset can be seen at `BigQuery > BigQuery Studio` in the left hand nav.<br> 
<img src="https://github.com/inner-outer-space/de-zoomcamp-2024/assets/12296455/f3b98a6b-5b58-4aec-b00c-ba325ab153d1" width="150" height="150" >
<br><br>

**TERRAFORM DESTROY** 
<br>
Running `terraform destroy` will look at state file and check what changes need to be made to get rid of the resources. 
- The plan is returned providing have a list of resources to be destroyed and their details.
- The terraform.tfstate.backup file is updated with the current state before the change.
- The terraform.tfstate file is updated with the state after the change.

[more on state files](https://www.devopsschool.com/blog/what-is-terraform-tfstate-backup-file-in-terraform/)

<br><br>
## USING VARIABLES
You can define variables in the `variable.tf` file and reference them from main.tf

<details>
<summary>variable.tf</summary> 
	
```terraform

variable "gcp_storage_location" {
  description = "Location for GCP bucket"
  default     = "EU"
}

variable project {
  description = "Project"
  default     = "aerobic-badge-408610"
}

variable "region" {
  description = "Region"
  default     = "europe-west1"
  
}

variable "bq_dataset_name" {
  description = "My BigQuery dataset"
  default     = "taxi_dataset"
}

variable "gcp_storage_class" {
  description = "Storage class for GCP bucket"
  default     = "STANDARD"
}

variable "gcs_bucket_name" {
  description = "Name for GCP bucket"
  default     = "aerobic-badge-408610-taxi-bucket"
}
```
</details>


<details>
<summary>main.tf with variables</summary> 
	
```terraform 
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.11.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

resource "google_storage_bucket" "taxi-bucket" {
  name          = var.gcs_bucket_name
  location      = var.gcp_storage_location
  force_destroy = true
}

resource "google_bigquery_dataset" "taxi-dataset" {
  dataset_id = var.bq_dataset_name
  location   = var.gcp_storage_location
}
```
</details>

<details>
<summary>USING THE CREDENTIAL VARIABLE</summary> 

```terraform

# variable.tf
variable "credentials"  {
  description = "Credentials for GCP"
  default     = "path_to_key/key.json"
}

#main.tf
provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}
```
</details>

