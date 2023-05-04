# Module 1 - Getting Started with Python development for Cloud

## Basic Setup

Make sure you've completed the steps in [Basic Setup](./Readme.md) before moving forward with this module.

## Understanding the Cloud Shell Editor

Go to the [GCP Console](https://console.cloud.google.com) for your Qwiklabs project. Once there, enable the Cloud Shell Editor, you'll be working from there from now on.

**Discussion: A walkthrough Cloud Shell Editor**

## Understanding Python tooling

Python requires some tooling to get startedl. You will briefly see some of the most important tools that you'll need so you can start developing Python apps that will be deployed in the Cloud.

### Creating a basic local project structure
 
First, let's create a simple project structure by creating a directory to hold all our stuff:

```bash
touch $HOME/.labenv_custom.bash
echo "export WORKDIR="$HOME/code/myfirstapp"" >> "$HOME/.labenv_custom.bash"
source $HOME/.labenv_custom.bash
mkdir -p $WORKDIR/src
```

Inside this folder, let's create a basic structure for our service:

```bash
cd $WORKDIR
```

**Discussion: project/folder structures and languages**

### Managing Python versions with Pyenv

Install `pyenv` by running:

```bash
curl https://pyenv.run | bash
```

and then, setup your bash environment:
```bash
cat << "EOF" >> "$HOME/.labenv_custom.bash"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
```

Don't forget to source the new file:
```
. "$HOME/.labenv_custom.bash"
```

Test that pyenv is working:
```bash
pyenv --help
```

We'll be using Python 3.11, that we need to install in our system:
```bash
pyenv install --list | grep '^\s*3\.11.*'
pyenv install 3.11.3
```

This will take a while. Relax and maybe grab a cup of coffee.

Set Python 3.11.3 as our global version:
```bash
pyenv global 3.11.3
pyenv versions
```

Now, test that the proper version is active and everything is working as it should:
```bash
python --version
```

### Virtual Environments

Create a new virtual environment in our project folder:
```bash
cd $WORKDIR
python -m venv .venv
```

Now, activate the environment:
```bash
. .venv/bin/activate
```

If everything went well, the just activated virtual environment should show up in you command prompt.

### Python Packaging System

For Python packages, you'll be using `pip`. Make sure `pip` is the latest version inside your virtual environment:

```bash
echo $VIRTUAL_ENV
python -m pip install --upgrade pip
```

**Discussion: the relevance of quality batteries included tooling and packaging**

**Discussion: Why does this all matter for Cloud?**

## Creating our first application

Go to the `src` folder that will be holding all our Python code:

```bash
cd $WORKDIR/src
```

You'll be using Flask, so use `pip` to install it so you can test your app locally:
```bash
pip install flask
pip freeze > "$WORKDIR/requirements.txt"
```

Now open a new editor window:
```
cloudshell edit main.py
```

And type or paste the following code:
```python
import os

from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    name = os.environ.get("NAME", "World")
    return f"Hello {name}!"

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
```

As you're using Gunicorn, you'll also need to install it as a dependency:

```bash
pip install gunicorn
pip freeze > $WORKDIR/requirements.txt
```

Now, test locally your application:

```bash
python $WORKDIR/src/main.py
```

Open a new terminal, and request the main page running in port 8080. For this to run in the browser, you'd need to open a Preview in port 8080, so for now you'll use `curl`:
```bash
curl localhost:8080
```

Close the previous gunicorn instance by pressing `Ctrl-C`.

Review your app dependencies so far, these will have to be included in your container image when we package the application:

```bash
bat $WORKDIR/requirements.txt
```

### Rye [Optional]

[Rye](https://github.com/mitsuhiko/rye) is the new Flask's creator management tool for Python. It mitigates a lot of problems that currently exist with the Python ecosystem. Only for Mac OS X and Linux.

The tool is written in Rust, so to try it out it's necesssary to install it on your environment:

```bash
curl https://sh.rustup.rs -sSf | sh
```

Select `1 (default)` when asked.

Then, install Rye:
```bash
source .bashrc
git config --global init.defaultBranch main
cargo install --git https://github.com/mitsuhiko/rye rye
```

Create a new sample project to learn how to manage the Python environment with Rye:
```bash
mkdir -p $HOME/code/hello-rye
cd $HOME/code/hello-rye
```

Now, you'll use it to manage Python binary distrubutions, virtual environments, packages and more.

Init Rye in your project folder:
```bash
rye init
```

Then, run `rye sync` as suggested by the `rye init` output you you let Rye do the basic setup for your project:
```bash
rye sync
```

Use it to pin a specific Python version (3.10) to the project:
```bash
rye pin 3.10
rye sync
```

Inspect the `pyproject.toml` file:
```bash
bat pyproject.toml
```

Also, note how the pinned Python version has been registered:
```bash
bat .python-version
```

Install a dependency, like flask and gunicorn:
```bash
rye add flask gunicorn
rye sync
```

Observe how the dependencies have been registered:
```bash
bat requirements.lock
```

Finally, enable the virtual environment and test some main.py Python code inside the `src/` directory
```bash
cp $WORKDIR/src/main.py $HOME/code/hello-rye/src/hello_rye
source .venv/bin/activate
cd $HOME/code/hello-rye/src/hello_rye
python main.py
```

There's much more to Rye, this is just scratching the surface of what seems like a very promising tool.

**Discussion: How does this compare to the methods outlined before?**

### Packaging the application into a container image:

You will now create the necessary Dockerfile specifying how the container image should be built. 

```bash
cd $WORKDIR
cloudshell open-workspace .
cloudshell edit Dockerfile
```

Type the following file in the `Dockerfile` file:

```Dockerfile
# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.11-slim

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY ./src ./
COPY requirements.txt ./

# Install production dependencies.
RUN pip install \
  --no-cache-dir \
  --disable-pip-version-check \
  --root-user-action=ignore \
  -r requirements.txt

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
# Timeout is set to 0 to disable the timeouts of the workers to allow Cloud Run to handle instance scaling.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
```

**Discussion: what's a container image? What's a Dockerfile useful for?**

Now, add the following `.dockerignore` file as to not include unnecessary clutter into your container image:

```text
Dockerfile
README.md
**/*.pyc
**/*.pyo
**/*.pyd
**/__pycache__
**/.pytest_cache
```

You also need to enable the Cloud Run Service in your GCP project:
```bash
gcloud services enable run.googleapis.com
```

### Building and publishing a container with Docker

First, you'll need a new Docker Artifact Repository where to push your image:
```bash
gcloud artifacts repositories create docker-main --location=europe-west1 --repository-format=docker
gcloud artifacts repositories list
```

Now, build your image tagging using Docker. Tag it with the proper Artifact Registry ID (it should follow the convention `LOCATION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE`):
```bash
gcloud artifact 
docker build -t "$REGION-docker.pkg.dev/$PROJECT_ID/docker-main/myfirstapp" .
```

Check that you've got the image locally:
```bash
docker image ls
```

Where's the image? You can check how the image is hosted in your local Cloud Shell:
```bash
sudo ls /var/lib/docker/image/overlay2/imagedb/content/sha256
sudo cat /var/lib/docker/image/overlay2/imagedb/content/sha256/* | jq
```

Run the container locally:
```bash
docker run -e PORT=8080 -p 8080:8080 $REGION-docker.pkg.dev/$PROJECT_ID/docker-main/myfirstapp
```

### Pushing the image to a remote registry

You'll now push the image to a remote registry where Cloud Run can pull the image from. For this to work, you'll need configure Docker so it has the right credentials to push images to the Artifact Registry Docker repository that you created in the steps above:
```bash
gcloud auth configure-docker $REGION-docker.pkg.dev
docker push $REGION-docker.pkg.dev/qwiklabs-gcp-04-219ef26f6927/docker-main/myfirstapp
```

List the images in the remote repository and check that your image is now there:
```bash
gcloud artifacts docker images list $REGION-docker.pkg.dev/$PROJECT_ID/docker-main
```

Finally, use the Google Cloud SDK to tell Cloud Run to fetch the image from the Artifact Registry repo and deploy it:
```bash
gcloud run deploy myfirstapp \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/docker-main/myfirstapp \
  --allow-unauthenticated
```

### Building and publishing a container with Cloud Build

You don't have to use any local tooling to build images, Cloud Build can do that for you.

You'll now rebuild the container image from the Dockerfile specification using the Docker Cloud Build builder and the Google Cloud SDK:

```bash
cd $WORKDIR
gcloud builds submit -t $REGION-docker.pkg.dev/$PROJECT_ID/docker-main/myfirstapp .
```

Note how here, instead of creating an image locally and uploading it to Artifact Registry, Cloud Build is zipping the source code and uploading it to the Cloud. Cloud Build will get it in a Google Cloud Storage bucket and will proceed to build an image from it.

You can now deploy this image version using `gcloud`:
```bash
gcloud run deploy myfirstapp \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/docker-main/myfirstapp \
  --allow-unauthenticated
```

### Further automating the build and deploy process with the Google Cloud SDK

The Google Cloud SDK includes tooling so you don't even have to explicitly do the container image building. Run the following command and observe what's happening:

```bash
cd $WORKDIR
gcloud run deploy myfirstapp --source . --allow-unauthenticated
```