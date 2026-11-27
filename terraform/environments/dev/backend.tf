# State distant dans GCS : https://developer.hashicorp.com/terraform/language/backend/gcs
# Le nom du bucket est fourni à l'init : terraform init -backend-config="bucket=<BUCKET>"
terraform {
  backend "gcs" {
    prefix = "terraform/dev"
  }
}
