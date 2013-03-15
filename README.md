Ansible tutorial
================

This tutorial presents ansible step-by-step. You'll need to have a (virtual or
physical) machine to act as an ansible node. A vagrant environment is provided for 
going through this tutorial.

Ansible is a configuration management software that let's you control and
configure nodes from  another machine. What makes it different from other
management software is that ansible  uses (pottentially existing) SSH
infrastructure, while others (chef, puppet, ...) need a specific PKI
infrastructure to be set-up.

Ansible also emphasises push mode, where configuration is pushed from a master
machine (a master machine is only a machine where you can SSH to nodes from) to
nodes, while most other CM typically do it the other way around (nodes pull
their config at times from a master machine).

This mode is really interesting since you do not need to have a publicly
accessible 'master' to be able to configure remote nodes : it's the nodes
that need to be accessible (we'll see later that 'hidden' nodes can pull their
configuration too!), and most of the time they are.

# Prerequisites for Ansible

You need the following python modules on your machine (the machine you run ansible 
on) 
- python-yaml
- python-jinja2

On Debian/Ubuntu run:
``sudo apt-get install python-yaml python-jinja2 python-paramiko python-crypt``

We're also assuming you have a keypair in your ~/.ssh directory.

# Installing Ansible

## From source

Ansible devel branch is always usable, so we'll run straight from a git checkout.
You might need to install git for this (`sudo apt-get install git` on Debian/Ubuntu).

    git clone git://github.com/ansible/ansible.git
    cd ./ansible

At this point, we can load the ansible environment :

    source ./hacking/env-setup

## From a deb package

When running from an installed package, this is absolutely not necessary. If
you prefer running from a debian package ansible, provides a `make target` to
build it. You need a few packages to build the deb :

    sudo apt-get install make fakeroot cdbs python-support
    git clone git://github.com/ansible/ansible.git
    cd ./ansible
    make deb
    sudo dpkg -i ../ansible_1.1_all.deb (version may vary)

We'll assume you're using the deb packages in the rest of this tutorial.

# Using Vagrant with the tutorial

It's highly recommended to use Vagrant to follow this tutorial. If you don't have 
it already, setting up should be quite easy and is described in [step-00/README.md](https://github.com/leucos/ansible-tuto/tree/master/step-00/README.md).

If you wish to proceed without Vagrant (not recommended !), go straight to 
[step-01/README.md](https://github.com/leucos/ansible-tuto/tree/master/step-01).

## Contents

Just in case you want to skip to a specific step, here is a topic table of contents.

- [00. Vagrant Setup](https://github.com/leucos/ansible-tuto/tree/master/step-00)
- [01. Basic inventory](https://github.com/leucos/ansible-tuto/tree/master/step-01)
- [02. First modules and facts](https://github.com/leucos/ansible-tuto/tree/master/step-02)
- [03. Groups and variables](https://github.com/leucos/ansible-tuto/tree/master/step-03)
- [04. Playbooks](https://github.com/leucos/ansible-tuto/tree/master/step-04)
- [05. Playbooks, pushing files on nodes](https://github.com/leucos/ansible-tuto/tree/master/step-05)
- [06. Playbooks and failures](https://github.com/leucos/ansible-tuto/tree/master/step-06)
- [07. Playbook conditionals](https://github.com/leucos/ansible-tuto/tree/master/step-07)
- [08. Git module](https://github.com/leucos/ansible-tuto/tree/master/step-08)
- [09. Extending to several hosts](https://github.com/leucos/ansible-tuto/tree/master/step-09)
- [10. Templates](https://github.com/leucos/ansible-tuto/tree/master/step-10)
- [11. Variables again](https://github.com/leucos/ansible-tuto/tree/master/step-11)
