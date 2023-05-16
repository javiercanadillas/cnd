
# Developing using VSCode Remote Server against Cloud Shell

Install the Google Cloud SDK in your local machine. Instructions depend on your laptop Operating System platform, so it's better to point you to the [official instructions to get them installed](https://cloud.google.com/sdk/docs/install#windows).

For Mac OS X though, I'd strongly recommend you to [install Homebrew in your machine](https://docs.brew.sh/Installation), and then use to install any kind of software really. With it, you can install the Google Cloud SDK with a single command:

```bash
brew install --cask google-cloud-sdk
```

## Installing VSCode

There's Vim, there's Emacs... there are plenty of good code editors out there. But one that's very popular lately is VSCode. This tutorial will focus on it because it's very similar in developing experience to the one you get when you use the [Cloud Shell Editor](https://cloud.google.com/shell/docs/editor-overview).

Again, because your OS may be different than mine, the best pointer to install VSCode in your machine is the [official installation docs](https://code.visualstudio.com/download).

If you happen to be on Mac OSX, using Homebrew is just one liner:

```bash
brew install visual-studio-code
```

If you open it, I recommend you to install several useful plugins for Cloud Python development:

- Docker (from Microsoft)
- Python (from Microsoft)
- Ruff - a very fast Python linter
- Cloud Code (from Google) - A extension to integrate your vscode environment with Google Cloud services.

## Setting up local connection to remote Cloud Shell

OK, you have the Google Cloud SDK installed in your computer. Now what? It's time to learn how to se up your local vscode so you get Cloud Shell Terminal and Cloud Shell files into it in an integrated way.

Open a terminal in your laptop and type the following command:

```bash
gcloud cloud shell ssh --dry-run --authorize-session
```

This outputs the command that `gcloud` would use if you were to connect through SSH from your local terminal to Cloud Shell, but does not actually establishes the connection. This allows you to see the Cloud Shell VM IP, that you will need to use to connect to it from vscode.

So, from the command output, copy and paste the VM IP that's there. You will use it when connecting from vscode.

Open VScode, press `Cmd + Shift + P` (or `Ctrl + Shift + P` if you're in Windows or Linux), and type/select "Remote-SSH: Connect to Host..." in the window that appears there:

![Connect to host](https://miro.medium.com/v2/resize:fit:1400/0*tQFfJwZLBOzCggGI)

You will next be asked to add a host entry to the config file with the IP address and user account as the only details that are specific to you. This file is saved as config in the ~/.ssh folder if you're using a Linux or Mac computer.

~[ssh config file](https://miro.medium.com/v2/resize:fit:1400/0*buPytl9Prsd9U__w)

Now, you should be able to connect to Cloud Shell. Use `Cmd +  Shift + P` (or `Ctrl + Shift + P`) again in VSCode and type/select the option "Remote-SSH: Connect to Host..."

VSCode should open a new window, and in that window whatever you're doing, you're doing in the Remote Cloud Shell (both opening files and opening terminals will happen remotely in Cloud Shell).