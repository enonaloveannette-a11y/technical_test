# technical_test
# DevOps Technical Test — PHP app on GCP

#1- Contexte

Test technique DevOps, où il était question de déployer une app PHP sur GCP en utilisant la technologie IAS terraform

L'application est une page PHP qui affiche la version de PHP et l'environnement, et teste la connexion à la base MySQL (message « OK » ou « Échec »). Les configurations viennent des variabless d'environnement.

Le dépôt contient:
l'application dans un conteneur Docker (Nginx + PHP-FPM)
Les modules Terraform (Cloud SQL, Cloud Storage, Cloud Run)
La CI GitHub Actions avec les tests PHPUnit, 
Script Bash qui retrouve l'URL du service.

# 2- Structure

Le repo contient 4 dossiers principaux repartis comme suit



- app/ — PHP application (`index.php`, helper functions, stylesheet), its PHPUnit tests, and the Dockerfile that runs Nginx and PHP-FPM in a single container listening on port 8080.
- terraform/modules/ — reusable modules: `storage` (Cloud Storage bucket), `cloudsql` (MySQL instance, database and user), `cloudrun` (service account, Cloud Run service, public access). The `loadbalancer` module is a placeholder and is not implemented.
- terraform/environments/dev/ — the dev environment: provider and version constraints, variables, `terraform.tfvars`, the remote state backend (`backend.tf`), and the module calls.
- .github/workflows/pipeline.yml — GitHub Actions pipeline that runs the PHP tests on every push to `main`.
- scripts/get-service-url.sh — Bash script that retrieves the Cloud Run service URL for a given environment.

# 3- Variables Terraform

| Variable | Rôle | Valeur par défaut |
|---|---|---|
| `project_id` | Identifiant du projet GCP | aucune |
| `region` | Région des ressources | `europe-west1` |
| `bucket_name` | Nom du bucket Cloud Storage (unique au monde) | aucune |
| `db_name` | Nom de la base MySQL | aucune |
| `db_user` | Utilisateur MySQL de l'application | aucune |
| `db_password` | Mot de passe MySQL (sensible, jamais commité) | aucune |
| `image` | Chemin complet de l'image Docker dans Artifact Registry | aucune |
| `environment` | Nom de l'environnement, utilisé dans les noms | `dev` |

Le mot de passe passe par l'environnement : `export TF_VAR_db_password='<mot-de-passe>'`.

# 4-Lancer Terraform

a. Se connecter et choisir le projet :
```bash
gcloud auth login
gcloud config set project <ID_DU_PROJET>
```

b. Activer les API nécessaires :
```bash
gcloud services enable run.googleapis.com sqladmin.googleapis.com artifactregistry.googleapis.com iam.googleapis.com
```

c. Créer le bucket qui stocke l'état Terraform (une seule fois) :
```bash
gcloud storage buckets create gs://<BUCKET_ETAT> --location=europe-west1
```

d. Créer le dépôt d'images, puis construire et pousser l'image :
```bash
gcloud artifacts repositories create php-app --repository-format=docker --location=europe-west1
gcloud auth configure-docker europe-west1-docker.pkg.dev
docker build -t <IMAGE> app
docker push <IMAGE>
```

e. Déployer :
```bash
cd terraform/environments/dev
export TF_VAR_db_password='<mot-de-passe>'
terraform init -backend-config="bucket=<BUCKET_ETAT>"
terraform plan
terraform apply
```

# 5- Accéder à l'application

Après `terraform apply`, l'URL du service est dans l'output `service_url`.
Le script `./scripts/get-service-url.sh dev` la retrouve aussi.

# 6- Script Bash

`scripts/get-service-url.sh <environnement>` cherche le service Cloud Run `php-app-<environnement>` et affiche son URL. Il vérifie l'argument et la présence de `gcloud`, s'arrête à la première erreur et journalise chaque étape avec l'heure dans `get-service-url.log`.

# 7- Résultat du déploiement

Le déploiement réel a été réalisé le 27/11/2026 sur GCP : le service Cloud Run `php-app-dev` répond, et la page affiche « Connexion base de données : OK » vers Cloud SQL. L'infrastructure a ensuite été détruite avec `terraform destroy` pour éviter les coûts.

# 8- Problèmes rencontrés

- **Facturation GCP** : compte de facturation fermé, carte refusée, projet non relié au compte. Les API ne pouvaient pas être activées, ce qui a retardé le déploiement réel jusqu'à la fin.
- **API non activées** : `cloudresourcemanager` manquait, ce qui a fait échouer l'attribution du droit `cloudsql.client` au premier `apply`. Activée, puis `apply` relancé.
- **GitHub** : le token n'avait pas la permission `workflow` (push refusé), puis le workflow ne se lançait pas (mauvaise branche en déclencheur).
- **Terraform** : erreurs de noms de variables, `bucket_name` écrit entre guillemets (pris comme texte), backend GCS à initialiser avec un bucket créé au préalable.

# 9- Limites et temps passé

- Le **load balancer HTTP(S)** n'est pas implémenté (le module est un squelette).
- La CI exécute les tests PHPUnit ; le déploiement vers Cloud Run n'est pas automatisé.


# 10- Pistes pour la production

- Mot de passe dans **Secret Manager** plutôt qu'en variable d'environnement.
- **Workload Identity Federation** plutôt qu'une clé de service pour la CI.
- État Terraform versionné, un projet par environnement.

