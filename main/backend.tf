terraform {
  backend "gcs" {
    bucket = "lanchonete-terraform-backend"
    prefix = "infra_sqs_hackaton/terraform.tfstate"
  }
}
