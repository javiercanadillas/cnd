# Connecting to Cloud SQL from Cloud Run
## Create a Cloud SQL Postgre Database

The first thing to do is to create the necessary Cloud Infrastructure, starting with the Cloud SQL Postgre instance and database.

Enable the Cloud SQL Admin API:
```bash
gcloud services enable sqladmin.googleapis.com
```

Set the SQL database connection variables:
```bash
cat << EOF >> .labenv_db
DB_INSTANCE=myinstance
DB_NAME=mydatabase
DB_USER=postgres
DB_PASS=postgres
INSTANCE_CONNECTION_NAME="$PROJECT_ID:$REGION:$DB_INSTANCE"
export DB_INSTANCE DB_NAME DB_USER DB_PASS INSTANCE_CONNECTION_NAME
EOF
source ./.labenv_db
```

Create a Cloud SQL - PostgreSQL instance:
```bash
gcloud sql instances create "$DB_INSTANCE" \
  --tier=db-g1-small \
  --region="$REGION" \
  --database-version=POSTGRES_14
```

Store the instance IP address in an environment variable:
```bash
echo "export SQL_IP="$(gcloud sql instances describe "$DB_INSTANCE" --format="value(ipAddresses[0].ipAddress)")"" >> .labenv_db
source ./.labenv_db
```

Set the password for the default user:
```bash
echo $DB_PASS
gcloud sql users set-password postgres \
  --instance=myinstance\
  --password=$DB_PASS
```

Create a database:
```bash
gcloud sql databases create $DB_NAME --instance=$DB_INSTANCE
```

## Create the application

You'll now create a new structure for this new application.

Create a new folder structure and activate the environment:
```bash
mkdir -p $HOME/cnd/db-api/src
cd $HOME/cnd/db-api
source .venv/bin/activate
```

Let's use `pip-tools` for a saner dependency management:
```bash
pip install pip-tools
cp $HOME/cnd/assets/module3/requirements-local.in ./requirements-local.in
pip-compile ./requirements-local.in -o requirements.txt
pip-sync
```

Copy the code and use it to create a table with data:
```bash
cd src/
cp $HOME/cnd/assets/module3/create_db.py .
python create_db.py
```

Observe how a new table is created in the database and the entries are logged back by the program.

This works as is from Cloud Shell without requiring further authentication configuration in the code because the code is using Google Cloud SDK's [Application Default Credentials](https://cloud.google.com/docs/authentication/provide-credentials-adc).

## Create a Cloud Run Flask-based API

