# Connecting to Cloud SQL from Cloud Run

Connecting to databases is one of the most common operations to be done when developing Cloud Nativa applications. This is like so because serverless platforms like Cloud Run rely on them to persist data due to the very stateless nature of these platforms.

In this mode, you'll learn how to connect to one of the most common types of Databases in real life companies.
## Create a Cloud SQL Postgre Database

The first thing to do is to create the necessary Cloud Infrastructure, starting with the Cloud SQL Postgre instance and database. Cloud SQL offers you some other options (MySQL and SQLServer), but PosgreSQL seems to be an option that's widely used nowadays.

Connect to your Cloud Shell environment and enable the Cloud SQL Admin API:
```bash
gcloud services enable sqladmin.googleapis.com
```

Then, set the SQL database connection variables that the next steps will be using and persist them into a file:

```bash
cd $HOME/cnd/db-api
cat ./assets/module3/labeven_extra >> .labenv_db
```

It's a good idea to have a look at what you've added to your shell to understand what you're doing before applying the changes:
```bash
bat .labenv_db
```

Notice how you're setting the variables to create and establish the database connection. You'll be using these variables in the next steps.

Now, make the changes effective:
```bash
source ./.labenv_db
```

Create a new Cloud SQL - PostgreSQL database instance using `gcloud` and selecting the `db-g1-small` machine type to reduce costs:
```bash
gcloud sql instances create "$DB_INSTANCE" \
  --tier=db-g1-small \
  --region="$REGION" \
  --database-version=POSTGRES_14
```

Store the instance IP address in an environment variable and persist it into the environment file that you created before:
```bash
echo "declare -x SQL_IP="$(gcloud sql instances describe "$DB_INSTANCE" --format="value(ipAddresses[0].ipAddress)")"" >> .labenv_db
source ./.labenv_db
```

Set the password for the default user in the database:
```bash
echo $DB_PASS
gcloud sql users set-password postgres \
  --instance=myinstance\
  --password=$DB_PASS
```

Create a new database in the database instance you've just created:
```bash
gcloud sql databases create $DB_NAME --instance=$DB_INSTANCE
```

You now have all the infrastructure you need.
## Create the application

You'll now create a new structure for a new Cloud Run service that you will be developing. This new service will be called `db-api`, and will wrap our application specific database operations through an API built with Flask.

Create a new folder structure for your code, and a new python environment inside it:
```bash
mkdir -p $HOME/cnd/db-api/src
cd $HOME/cnd/db-api
python -m venv .venv
source .venv/bin/activate
```

Note how you enabled the virtual environment, so any Python package management is done inside it.

You will now uuse `pip-tools` for a saner dependency management:
```bash
pip install pip-tools
cp $HOME/cnd/assets/module3/requirements-local.in ./requirements-local.in
pip-compile ./requirements-local.in -o requirements.txt
pip-sync
```

This just took a simple `requirements-local.in` requirements file that only has the two required dependencies for now, defined in an explicit way, and generates a `requirements.txt` file with all the subdependencies, adding comments to track which dependencies are coming from which. The last `pip-sync` is just making sure that the `requirements.txt` file is processed by pip and that everything is consistent.


Copy the `create_db.py` code file and run it. This file contains code to create a table with data into the database you created previously.
```bash
cd src/
cp $HOME/cnd/assets/module3/create_db.py .
python create_db.py
```

Observe how a new table is created in the database and the entries are logged back by the program to your console.

You can always test the database connection with another Python program:
```bash
python $HOME/cnd/assets/module3/test_db.py
```

If you do so, you should see one entry in the database.

This works as is from Cloud Shell without requiring further authentication configuration in the code because the code is using Google Cloud SDK's [Application Default Credentials](https://cloud.google.com/docs/authentication/provide-credentials-adc).

## Create a Cloud Run Flask-based API
