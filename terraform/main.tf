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
