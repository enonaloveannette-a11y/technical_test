module "storage" {
  source      = "../../modules/storage"
  bucket_name = var.bucket_name
  location    = var.region
  project_id  = var.project_id
}

module "cloudsql" {
  source        = "../../modules/cloudsql"
  project_id    = var.project_id
  region        = var.region
  instance_name = "mysql-test"
  database_name = var.db_name
  db_user       = var.db_user
  db_password   = var.db_password
}

module "cloudrun" {
  source             = "../../modules/cloudrun"
  project_id         = var.project_id
  region             = var.region
  service_name       = "php-app-${var.environment}"
  image              = var.image
  db_connection_name = module.cloudsql.connection_name
  db_name            = var.db_name
  db_user            = var.db_user
  db_password        = var.db_password
  environment        = var.environment
}
