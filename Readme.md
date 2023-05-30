# Cloud Native Development Labs

This is the lab content repository for the Cloud Native Development (with Python and Cloud Run) class '23. The following instructions and modules assume you're using a Qwiklabs environment. Make sure you ask your instructor for specific instructions on how to access it.

## Basic Setup

Open a new [Google Cloud Shell](shell.cloud.google.com) in your Qwiklabs project. Set up your project and preferred region:
```
gcloud config set project <your-qwiklabs-project-id>
gcloud config set compute/region <your-preferred-cloud-region>
```

Then, run the following Cloud Shell configuration script:
```
CS_SOURCE="https://raw.githubusercontent.com/javiercanadillas/qwiklabs-cloudshell-setup/main/setup_qw_cs"
bash <(curl -s "$CS_SOURCE")
```

This configures a sane prompt that will give you hints on things like Python virtual environments or git status. For changes to be effective, you need to source the new `.bashrc` configuration:

```bash
. "$HOME/.bashrc"
```

Finally, clone this repo:

```bash
cd $HOME; git clone https://github.com/javiercanadillas/cnd
cd cnd
```

## Cloud Native Development with Python and Cloud Run

The following modules will walk you through the concepts you'll be practicing with in this lab:

- [Module 1 - Getting started with Python development for Cloud](./assets/module1/Module1.md)
- [Module 2 - Packaging into a container image and deploying into Cloud Run](./assets/module2/Module2.md)
- [Module 3 - Connecting to Cloud SQL from Cloud Run](./assets/module3/Module3.md)
- [Module 4 - Splitting into two microservices and using service accounts](./assets/module4/Module4.md)
- [Extra - Developing using VSCode Remote Server against Cloud Shell](./assets/extra/Remote_dev.md)
