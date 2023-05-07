# Module 2 - Packaging into a container image and deploying into Cloud Run

## Bootstrapping this module

If you have just followed module 1, there's nothing additional for you to do here.

However, **if you're starting fresh from a new Qwiklabs project**, you need to do the following steps:

1. Do the steps in the [Readme.md](../../Readme.md) file.
2. Bootstrap your environment:
  ```bash
  cd $HOME/cnd/assets/common
  ./bootstrap.bash
  ```
3. Source your `.bashrc` environment:
  ```bash
  source $HOME/.bashrc
  ```
4. Perform the module 1 steps in an automated way:
  ```bash
  cd $WORKDIR/assets/module1
  ./module1_steps.bash
  cd $WORKDIR

Now you should be ready to continue with Module 2. Read on.

## Packaging the application into a container image

You will now create the necessary Dockerfile specifying how the container image should be built. 

```bash
cd $WORKDIR/myfirstapp
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

As you'll be using Gunicorn, you'll also need to install it as a dependency. Come back to the terminal and type:

```bash
cd $WORKDIR/myfirstapp
source .venv/bin/activate
pip install gunicorn
pip freeze > $WORKDIR/requirements.txt
deactivate
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

### Building and publishing a container with Docker

Build your image tagging using Docker. Tag it with the proper Artifact Registry ID (it should follow the convention `LOCATION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE`):
```bash
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

You'll now push the image to a remote registry where Cloud Run can pull the image from.

The first thing you'll need is a Docker Artifact Registry where to push your image:
```bash
gcloud artifacts repositories create docker-main --location=europe-west1 --repository-format=docker
gcloud artifacts repositories list
```

For the docker daemon to be able to push images to a remote registry, you'll need to authenticate and authorize. This means configuring Docker so it has the right credentials to push images to the Artifact Registry docker registry that you created in the steps above:
```bash
gcloud auth configure-docker $REGION-docker.pkg.dev
docker push $REGION-docker.pkg.dev/qwiklabs-gcp-04-219ef26f6927/docker-main/myfirstapp
```

List the images in the remote repository and check that your image is there:
```bash
gcloud artifacts docker images list $REGION-docker.pkg.dev/$PROJECT_ID/docker-main
```

Finally, use the Google Cloud SDK to tell Cloud Run to fetch the image from the Artifact Registry repo and deploy it:
```bash
# You also need to enable the Cloud Run Service in your GCP project:
gcloud services enable run.googleapis.com
# And then deploy the app
gcloud run deploy myfirstapp \
  --image "$REGION-docker.pkg.dev/$PROJECT_ID/docker-main/myfirstapp" \
  --allow-unauthenticated \
  --set-env-vars="NAME=CND"
```

**Discussion: what's happening when you use the `--set-env-vars` option with the `gcloud` command?**

**Discussion: how can you test the app now?**

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
  --image "$REGION-docker.pkg.dev/$PROJECT_ID/docker-main/myfirstapp" \
  --allow-unauthenticated \
  --set-env-vars="NAME=CND"
```

Get the service URL so you can test it:
```bash
gcloud run services describe myfirstapp
```

### Further automating the build and deploy process with the Google Cloud SDK

The Google Cloud SDK includes tooling so you don't even have to explicitly do the container image building. Run the following command and observe what's happening:

```bash
cd $WORKDIR
gcloud run deploy myfirstapp \
  --source . \ 
  --allow-unauthenticated \
  --set-env-vars="NAME=CND"
```