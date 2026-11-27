# DevOps Technical Test — PHP app on GCP

## 1. Context

This is a DevOps technical test: deploy a PHP application on GCP using Infrastructure as Code with Terraform.

The application is a PHP page that displays the PHP version and the environment, and tests the connection to the MySQL database (message "OK" or "Failed"). The configuration comes from environment variables.

The repository contains:
- the application in a Docker container (Nginx + PHP-FPM)
- the Terraform modules (Cloud SQL, Cloud Storage, Cloud Run)
- the GitHub Actions CI with PHPUnit tests
- a Bash script that retrieves the service URL

## 2. Structure

The repository has four main folders:

- `app/` — PHP application (`index.php`, helper functions, stylesheet), its PHPUnit tests, and the Dockerfile that runs Nginx and PHP-FPM in a single container listening on port 8080.
- `terraform/modules/` — reusable modules: `storage` (Cloud Storage bucket), `cloudsql` (MySQL instance, database and user), `cloudrun` (service account, Cloud Run service, public access). The `loadbalancer` module is a placeholder and is not implemented.
- `terraform/environments/dev/` — the dev environment: provider and version constraints, variables, `terraform.tfvars`, the remote state backend (`backend.tf`), and the module calls.
- `.github/workflows/pipeline.yml` — GitHub Actions pipeline that runs the PHP tests on every push to `main`.
- `scripts/get-service-url.sh` — Bash script that retrieves the Cloud Run service URL for a given environment.

## 3. Terraform variables

| Variable | Description | Default |
|---|---|---|
| `project_id` | GCP project ID | none |
| `region` | Region of the resources | `europe-west1` |
| `bucket_name` | Cloud Storage bucket name (globally unique) | none |
| `db_name` | MySQL database name | none |
| `db_user` | MySQL user of the application | none |
| `db_password` | MySQL password (sensitive, never committed) | none |
| `image` | Full path of the Docker image in Artifact Registry | none |
| `environment` | Environment name, used in resource names | `dev` |

The password is passed through the environment: `export TF_VAR_db_password='<password>'`.

## 4. Running Terraform

a. Log in and select the project:
```bash
gcloud auth login
gcloud config set project <PROJECT_ID>
```

b. Enable the required APIs:
```bash
gcloud services enable run.googleapis.com sqladmin.googleapis.com artifactregistry.googleapis.com iam.googleapis.com
```

c. Create the bucket that stores the Terraform state (once):
```bash
gcloud storage buckets create gs://<STATE_BUCKET> --location=europe-west1
```

d. Create the image repository, then build and push the image:
```bash
gcloud artifacts repositories create php-app --repository-format=docker --location=europe-west1
gcloud auth configure-docker europe-west1-docker.pkg.dev
docker build -t <IMAGE> app
docker push <IMAGE>
```

e. Deploy:
```bash
cd terraform/environments/dev
export TF_VAR_db_password='<password>'
terraform init -backend-config="bucket=<STATE_BUCKET>"
terraform plan
terraform apply
```

## 5. Accessing the application

After `terraform apply`, the service URL is in the `service_url` output.
The script `./scripts/get-service-url.sh dev` also retrieves it.

## 6. Bash script

`scripts/get-service-url.sh <environment>` looks up the Cloud Run service `php-app-<environment>` and prints its URL. It checks the argument and that `gcloud` is installed, stops at the first error, and logs every step with a timestamp in `get-service-url.log`.

## 7. Deployment result

A real deployment was done on 27/11/2026 on GCP: the Cloud Run service `php-app-dev` responds, and the page displays "Database connection: OK" for Cloud SQL. The infrastructure will be destroyed after submission `terraform destroy` to avoid costs.

## 8. Problems encountered

- **GCP billing**: the billing account was closed, a card was refused, and the project was not linked to a billing account. APIs could not be enabled, which delayed the real deployment until the end.
- **APIs not enabled**: `cloudresourcemanager` was missing, so granting the `cloudsql.client` role failed on the first `apply`. I enabled it and re-ran `apply`.
- **GitHub**: the token did not have the `workflow` permission (push refused), then the workflow did not start (wrong branch in the trigger).
- **Terraform**: variable name errors, `bucket_name` written between quotes (treated as text), and the GCS backend needing a bucket created beforehand.

## 9. Limitations 

- The **HTTP(S) load balancer** is not implemented (the module is a skeleton).
- The CI runs the PHPUnit tests; deployment to Cloud Run is not automated.

## 10. Production ideas

- Store the password in **Secret Manager** instead of an environment variable.
- Use **Workload Identity Federation** instead of a service account key for the CI.
- Versioned Terraform state, one project per environment.
