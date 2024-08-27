# Tooling Setup Assignment

## Objectives

* Learn and describe the advantage using modern package managers on Windows and MacOS for tooling install
* Demonstrate the advantages of using version control for documentation distribution
* Learn and discuss the use of Markdown for text based document creation

## Outcome

At the end of this assignment you will have become familiar with industry standard package managers for Windows and MacOS and be able to install standard tooling used in Cloud Native application development. This will be achieved by following a small demo and some small tutorials.

## Overview

Complete the required installs in this document via a Package Manager and take a screenshot of the proper output to show a successful install. Place the screenshot into the document as mentioned in the last step.

## Tooling Assignment Part I

We will cover the initial installation of tools we will need for this semester.  If you have already completed this in a prior class, you could take the time to update your software or reach out and help a classmate and take a note that there are a few changes.

## Sample Code

Additional samples and tutorials are available at [https://github.com/illinoistech-itm/jhajek/tree/master/itmto-444-544](https://github.com/illinoistech-itm/jhajek/tree/master/itmto-444-544 "webpage for samples")

### Package Managers

Package Managers are an essential tool, originally created for Linux Distributions, apt and yum, at the turn of the century for managing installing software and collecting the proper dependencies. Only in recent years have the major desktop operating systems, Windows and MacOS, created similar tools. You may be more familiar with the term, "APP Store," the concept is the same either way.

Package Managers help by streamlining a few important items:

* Package Managers provide a centralized location for installing applications
  * This location is accessed through a Command Line tool
* Package Managers take care of all dependency installations
  * Any additional pieces or software or libraries are automatically installed for you
* Package Managers allow you to automate and script your installs
  * This makes installing a series of packages portable across systems
* Package Managers handle all PATH issues, updates, and single source to remove an application

### MacOS - Homebrew

Homebrew is the MacOS 3rd party package manager located at: [https://brew.sh/](https://brew.sh/ "brew installer page"). It is available for Intel and M1 based Macs -- the workflow doesn't change.

If you have a Mac - install brew and provide a screenshot of the output of the command: `brew --version`

![alt text](images/brew.png)

### Windows 10 21H1+ or 11

The name of the third party Windows Package manager is Chocolatey. The download is located at [Chocolatey.org](https://chocolatey.org/ "Chocolatey.org download page").

From an Administrator PowerShell 5 prompt:

```PowerShell
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol `
= [System.Net.ServicePointManager]::SecurityProtocol `
-bor 3072; iex ((New-Object `
System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

For Windows 10 or 11, place a screenshot of the version command output for: ```choco --version```.

### Commands to run and install all the software

**NOTE** if you have any of this software already installed, you do not need to reinstall it -- but it wouldn't hurt to upgrade everything so that we are all on the same versions.  Below I will describe what we are installing.

For MacOS using Homebrew:

```bash
brew install --cask powershell ; brew install --cask iterm2 ; brew install git ; brew install --cask visual-studio-code ; brew install --cask ; brew install virtualbox ; brew install --cask vagrant ; brew install packer
```

For M1 Macs you will run the same as above but without the VirtualBox install:

```bash
brew install --cask powershell ; brew install --cask iterm2 ; brew install git ; brew install --cask visual-studio-code ; brew install --cask vagrant ; brew install packer
```

* For M1 Macs you will need to make a purchase of a copy of Parallels Pro or Enterprise edition
  * [https://www.parallels.com/products/desktop/pro/](https://www.parallels.com/products/desktop/pro/ "Parallels Pro Edition")
  * The standard and education edition doesn't contain the commandline interface needed for automation.
* Once Vagrant and Parallels Pro Edition is installed you need to also install the Parallels SDK from the Download Tab in your parallels.com account
  * From the Terminal run the command: `vagrant plugin install vagrant-parallels`
    * This will add the needed plugin to allow you to use Parallels from Vagrant
    * This will also work if you have Parallels Pro Edition on an Intel Mac

For Windows 10 and 11 using Chocolatey:

```PowerShell
choco install powershell-core 
choco install microsoft-windows-terminal git vscode vscode-powershell vagrant packer virtualbox
```

### Installation of a Modern Shell

For Windows we are going to install PowerShell Core, also known as PowerShell 7.x. Windows includes PowerShell 5 (the light blue icon), which has ceased development and doesn't have support for modern font display.  PowerShell 7 is opensource and cross-platform available.  Working on Windows, PowerShell 7 is a must.

Open PowerShell 7 and issue the command: `ssh -V` and take a screenshot of the PowerShell version output as well as the SSH version output.

For MacOS, newer versions use the Z shell.  This is due to Apple not using GPLv3+ software, which newer versions of BASH are licensed under.  This should be just fine and not require a new shell install.  If you want to experiment you can also install PowerShell 7 via Brew but it is not required.

Open a terminal and type the commands: `zsh --version` and `ssh -V` and take a screenshot of the output

![alt text](images/zsh.png)
![alt text](images/ssh.png)

### Installation of a Modern Terminal

A Terminal is a way to run and manage multiple shell together, not unlike a web-browser, in a single managed window.  You will spend much time on in a shell during your career, the Terminal is a huge helper.

On Windows, Microsoft provides a [Windows Terminal](https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701?activetab=pivot:overviewtab "Install Windows Terminal from Microsoft Store")

Open the Windows Terminal and select from the drop down arrow, the ABOUT tab, and take a screenshot of the version output

On MacOS, there is a terminal called [iterm2](https://iterm2.com/ "MacOS shell terminal")

Open the iterm2 Terminal and from the File > About section take a screenshot of the version output

![alt text](images/iTerm.png)

### Install IDE editor with native version control support

We will be installing an text editor or and IDE for all of our coding and configuration.  The key is one with native version control tooling integrated.  There are many and all can be installed via your OSes package manager, here are a list:

* [VSCode from Microsoft](https://code.visualstudio.com/ "VSCode install")
  * Cross platform and has direct shell integration
* [Zed](https://zed.dev/download "Zed editor")
  * Built by by former Atom team (no windows currently)
* [Sublime Text](http://www.sublimetext.com/ "Submlime Text installer site")
  * Built for a MacOS native experience, A sophisticated text editor for code, markup and prose.  Available for all platforms.
* [Theia](https://theia-ide.org/ "Theia Editor")
  * Cross Platform development tool Eclipse Foundation

Take a screenshot from the ABOUT tab in your IDE to show the installed version

![alt text](images/VSC.png)

### Install Git Client for Version Control

Version Control is vital to modern software development and we will be using our Package Manger to install the Git Client for our respective operating systems. **Note**, this is different from the GitHub Desktop tool, which we will not be using this semester.

Take a screenshot of the output of the command: ```git --version```

![alt text](images/git.png)

#### Configure Git Client

You will need to configure Git if you already haven't done so.  From a shell run these two commands:

```bash
git config --global user.name "<Your Name>"
git config --global user.email "<youremail@example.com>"
```

My information would look like this:

```bash
git config --global user.name "Jeremy Hajek"
git config --global user.email "hajek@iit.edu"
```

![alt text](images/git-config.png)

### Install VirtualBox on Intel Macs or Windows

If you do not already have VirtualBox 7.x installed, use your package manager to install VirtualBox.  VirtualBox will be our virtualization platform we are using this semester. It is a robust opensource product and can be used to create and host machines on our local systems. It has integration with automation tools such as Packer and Vagrant from HashiCorp.

Take a screenshot of the VirtualBox > Help > About VirtualBox output or from the Terminal: `vboxmanage --version` (Windows or Intel MacOS)

### Install Virtualization Solutions for M1/M2 Macs

There are 4 options:

* Buying a Pro-license from Parallels 
  * [Pro License from Parallels](https://www.parallels.com/products/desktop/pro/ "Pro License form parallels.com website")
* Buy a license from VMware Fusion
  * [VMWare Fusion for Apple Silicon](https://blogs.vmware.com/teamfusion/2022/11/fusion-13-pro-and-player-are-here.html "webpage for fusion 13")
* Apple Native Silicon UTM
  * [UTM](https://mac.getutm.app/ "webpage for apple sillicon framework")
* Tart
  * [Tart is a virtualization toolset](https://tart.run/ "webpage to install Tart") to build, run and manage macOS and Linux virtual machines on Apple Silicon.
  
Whichever solution you choose - take a screenshot showing the installed version.

![alt text](images/parallels.png)

**Note:** that you can use Parallels on an Intel MacOS as well -- you would need to make sure you have the Pro edition installed and the SDK installed as well.

### Install Vagrant

Vagrant is a tool from [HashiCorp](https://hashicorp.com "HashiCorp website").  This tool is used to abstract away the VirtualBox interface and provide direct commandline access, increasing ease of use.  *Vagrant provides easy to configure, reproducible, and portable work environments built on top of industry-standard technology and controlled by a single consistent workflow to help maximize the productivity and flexibility of you and your team.*

Using your package manager, install the latest version of [Vagrant](https://vagrantup.com "Vagrant download site").  If you have a version 2.2.x you will be ok.  Note, if using Linux, do not use the built in package manager as these versions of Vagrant and Packer are too old and unmaintained.  

Take a screenshot of the output of the command: ```vagrant --version```

![alt text](images/vagrant.png)

### Install Packer.io

Packer is another automation tool from HashiCorp.  Whereas Vagrant was for running virtual machines, Packer's job is to build virtual machine images from a template language.  This tool allows fast infrastructure deployment, multi-provider portability, improved stability, and greater testability.

Using a package manager, install the latest version of [Packer](https://packer.io "Packer install site").  If you have a version > 1.6.x you will be ok. Note, if on Linux, do not use the built in package manager as these versions of Vagrant and Packer are too old and unmaintained.  

Take a screenshot of the output of the command: ```packer --version```

![alt text](images/packer.png)

### Final deliverable to Blackboard

Submit to Blackboard the URL to your GitHub private repo, so I can clone and see all these elements. You will submit URL's to the work in the Private GitHub repo to Blackboard, but the work will stay in GitHub.