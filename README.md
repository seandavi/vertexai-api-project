# GCP VertexAI infrastructure

This project aims to:

1. Provide terraform to set up VertexAI for use in an existing project.
2. Create a service account with access to the VertexAI API.
3. Generate and save a json key file for authentication using client SDKs
4. Allow end-to-end testing through running a python program that calls the VertexAI API using the created service key.




```hcl
# Set the required provider and project
provider "google" {
  project = var.project_id
}

# Enable the Vertex AI API
resource "google_project_service" "vertexai" {
  project = var.project_id
  service = "aiplatform.googleapis.com"
}

# Create a service account
resource "google_service_account" "vertexai_service_account" {
  account_id   = "vertexai-service-account"
  display_name = "Vertex AI Service Account"
  project      = var.project_id
}

# Grant the service account the necessary roles
resource "google_project_iam_member" "vertexai_service_account_roles" {
  for_each = toset([
    "roles/aiplatform.user",
    "roles/storage.objectAdmin",
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.vertexai_service_account.email}"
}

# Generate a service account key
resource "google_service_account_key" "vertexai_service_account_key" {
  service_account_id = google_service_account.vertexai_service_account.name
}

# Save the service account key to a JSON file
resource "local_file" "service_account_key_file" {
  content  = base64decode(google_service_account_key.vertexai_service_account_key.private_key)
  filename = "vertexai-service-account-key.json"
}

# Output the service account email and key file path
output "service_account_email" {
  value = google_service_account.vertexai_service_account.email
}

output "service_account_key_file_path" {
  value = local_file.service_account_key_file.filename
}

# Define the project_id variable
variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
}
```

Here's a brief explanation of the code:

1. We set the Google provider and specify the project using the `project_id` variable.

2. We enable the Vertex AI API using the `google_project_service` resource.

3. We create a service account using the `google_service_account` resource.

4. We grant the necessary roles to the service account using the `google_project_iam_member` resource. In this case, we assign the `roles/aiplatform.user` and `roles/storage.objectAdmin` roles to allow the service account to make calls to Vertex AI models and access storage.

5. We generate a service account key using the `google_service_account_key` resource.

6. We save the service account key to a JSON file using the `local_file` resource.

7. We output the service account email and the key file path using the `output` blocks.

8. We define the `project_id` variable to specify the Google Cloud project ID.


## Deploying infrastructure

To run the Terraform code and supply the `project_id`, you have a few options:

1. Using a `terraform.tfvars` file (recommended):
   - Create a file named `terraform.tfvars` in the same directory as your Terraform code.
   - Add the following line to the `terraform.tfvars` file, replacing `"your-project-id"` with your actual Google Cloud project ID:
     ```
     project_id = "your-project-id"
     ```
   - Run `terraform init` to initialize the working directory.
   - Run `terraform plan` to preview the changes.
   - Run `terraform apply` to create the resources.

2. Using command-line arguments:
   - Run `terraform init` to initialize the working directory.
   - Run `terraform plan -var 'project_id=your-project-id'` to preview the changes, replacing `your-project-id` with your actual Google Cloud project ID.
   - Run `terraform apply -var 'project_id=your-project-id'` to create the resources.

3. Using environment variables:
   - Set the `TF_VAR_project_id` environment variable to your Google Cloud project ID. The exact command depends on your operating system and shell:
     - On Linux or macOS (bash): `export TF_VAR_project_id=your-project-id`
     - On Windows (Command Prompt): `set TF_VAR_project_id=your-project-id`
     - On Windows (PowerShell): `$env:TF_VAR_project_id="your-project-id"`
   - Run `terraform init` to initialize the working directory.
   - Run `terraform plan` to preview the changes.
   - Run `terraform apply` to create the resources.

Regardless of the method you choose, make sure to replace `"your-project-id"` or `your-project-id` with your actual Google Cloud project ID.

Using a `terraform.tfvars` file is the recommended approach as it keeps the variable values separate from the Terraform code and allows for easy management of different environments or configurations.

## Testing using included python code

To test whether the infrastructure is set up correctly, run the following from the top level of the repository.

1. `python -m venv .venv` to create a virtual environment.
2. `source .venv/bin/activate` to activate the environment.
3. `pip install -r requirements.txt`
4. `python test_vertexai_api.py --json_key_file=terraform/vertexai-service-account-key.json`

This should run and produce output like that below:

```
Setting GOOGLE_APPLICATION_CREDENTIALS to terraform/vertexai-service-account-key.json
candidates {
  content {
    role: "model"
    parts {
      text: "**University of Colorado Anschutz Medical Campus**\n\n**Location:** Aurora, Colorado\n\n**History:**\n* Founded in 1996 as the Anschutz Medical Center\n* Renamed to the Anschutz Medical Campus in 2009\n* Became part of the University of Colorado system in 2012\n\n**Academics:**\n* Offers a wide range of health sciences programs, including:\n    * Medicine (MD)\n    * Nursing (BSN, MSN, DNP)\n    * Pharmacy (PharmD)\n    * Physical Therapy (DPT)\n    * Occupational Therapy (OTD)\n    * Speech-Language Pathology (MS, PhD)\n* Also offers graduate programs in biomedical sciences, public health, and health administration\n\n**Research:**\n* One of the top-ranked medical research institutions in the United States\n* Focuses on areas such as:\n    * Cancer\n    * Cardiovascular disease\n    * Neuroscience\n    * Infectious diseases\n\n**Clinical Care:**\n* Home to University of Colorado Hospital, a nationally recognized academic medical center\n* Provides a full range of clinical services, including:\n    * Primary care\n    * Specialty care\n    * Emergency care\n    * Trauma care\n    * Cancer treatment\n\n**Facilities:**\n* State-of-the-art facilities, including:\n    * Research laboratories\n    * Clinical simulation centers\n    * Teaching hospitals\n    * Student housing\n\n**Student Life:**\n* Vibrant student community with over 4,000 students\n* Numerous student organizations and clubs\n* Access to recreational facilities and outdoor activities\n* Located near the Denver metropolitan area, offering cultural and entertainment options\n\n**Notable Features:**\n* **Integrated Health Sciences:** The campus fosters collaboration between different health professions, promoting interdisciplinary care.\n* **Translational Research:** Focuses on bridging the gap between basic research and clinical practice, leading to innovative treatments.\n* **Patient-Centered Care:** Emphasizes patient engagement and personalized medicine.\n* **Community Involvement:** Partners with local organizations to improve health outcomes in the surrounding community."
    }
  }
  finish_reason: STOP
  safety_ratings {
    category: HARM_CATEGORY_HATE_SPEECH
    probability: NEGLIGIBLE
    probability_score: 0.0293678548
    severity: HARM_SEVERITY_NEGLIGIBLE
    severity_score: 0.0270147882
  }
  safety_ratings {
    category: HARM_CATEGORY_DANGEROUS_CONTENT
    probability: NEGLIGIBLE
    probability_score: 0.056966383
    severity: HARM_SEVERITY_NEGLIGIBLE
    severity_score: 0.0584532358
  }
  safety_ratings {
    category: HARM_CATEGORY_HARASSMENT
    probability: NEGLIGIBLE
    probability_score: 0.0496811531
    severity: HARM_SEVERITY_NEGLIGIBLE
    severity_score: 0.0165931769
  }
  safety_ratings {
    category: HARM_CATEGORY_SEXUALLY_EXPLICIT
    probability: NEGLIGIBLE
    probability_score: 0.103748634
    severity: HARM_SEVERITY_NEGLIGIBLE
    severity_score: 0.0109023741
  }
}
usage_metadata {
  prompt_token_count: 14
  candidates_token_count: 436
  total_token_count: 450
}
```
