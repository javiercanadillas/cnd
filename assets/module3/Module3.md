## Create a Firestore Database
```bash
source .ven/bin/activate
pip install google-cloud-firestore
```

(optionally, install the `firebase-admin` package instead of `google-cloud-firestore`)

```bash
source .venv/bin/activate
pip install firebase-admin
```

## Create a Cloud SQL Database

Enable the Cloud SQL Admin API:
```bash
gcloud services enable sqladmin.googleapis.com
```

Set the SQL database connection variables:
```bash
cat << EOF >> ~/.labenv_custom
export SQL_INSTANCE=myinstance
export SQL_DATABASE=mydatabase
export SQL_USER=postgres
export SQL_PASSWORD=postgres
EOF
source ~/.labenv_custom
```

Create a Cloud SQL - PostgreSQL instance:
```bash
gcloud sql instances create "$SQL_INSTANCE" \
  --tier=db-g1-small \
  --region="$REGION" \
  --database-version=POSTGRES_14
```

Store the instance IP address in an environment variable:
```bash
echo "export SQL_IP="$(gcloud sql instances describe "$SQL_INSTANCE" --format="value(ipAddresses[0].ipAddress)")"" >> ~/.labenv_custom
source ~/.labenv_custom
```

Set the password for the default user:
```bash
gcloud sql users set-password postgres \
  --instance=myinstance\
  --password=$SQL_PASSWORD
```

Create a database:
```bash
gcloud sql databases create mydatabase --instance=myinstance
```

Import python packages:
```bash
cd $HOME/cnd/db-api
source .venv/bin/activate
pip install sqlalchemy "cloud-sql-python-connector[pg8000]" flask
```
