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

## Cloud Native Development with Python and Cloud Run

The following modules will walk you through the concepts you'll be practicing with in this lab:

- [Module 1 - Getting started with Python and Cloud Run](./Module1.md)
