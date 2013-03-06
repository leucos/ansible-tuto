Ansible tutorial
----------------

This tutorial presents ansible step-by-step. You'll need to have a (vitual of
physical) machine to act as an ansible node.

Ansible is a configuration management software that let's you control and
configure nodes from  another machine. What makes it different from other
management software is that ansible  uses (pottentially existing) SSH
infrastructure, while others (chef, puppet, ...) need a specific PKI
infrastructure  to be set-up.

Ansible also emphasises push mode, where configuration is pushed from a master
machine  (a master machine is only a machine where you can SSH to nodes) to
nodes, while most other CM typically do it the other way around (nodes pull
their config at times from a master machine).

This mode is really intsresting since you do not need to have a publicly
accessible  'master' to be able to configure remote nodes : it's the nodes
that need to be accessible (we'll see later that 'hidden' nodes can pull their
configuration too !), and most of the time they do since they're servers.

# Prerequisites

You need the following python modules on your machine (the machine you run ansible 
on) 
- python-yaml
- python-jinja2

    sudo apt-get install python-yaml python-jinja2 python-paramiko python-crypt

We're also assuming you have a keypair in your ~/.ssh directory.

# Installing

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

We'll assume we're using the deb packages in the rest of this document.

# Inventory

Before continuin, you need an inventory file. The default place for such a
file is  `/etc/ansible/hosts`. However, you can configure ansible to look
somewhere else, use an environment variable, or use the `-i` flag in ansible
commands an provide the inventory path.

For now, we'll create an inventory file in our home dir and use an environment
variable :

    echo "localhost" > ~/hosts
    export ANSIBLE_HOSTS=~/hosts

# Testing

Now that ansible is installed, let's check everything works properly.

    ansible -m ping localhost --ask-pass

Ansible will ask for your own password. The output should look like this :

    localhost | success >> {
        "changed": false, 
        "ping": "pong"
    }

What ansible is doing here is just connecting locallly (`localhost`) and
executing  the `ping` module (more on modules later). When ansible tries to
connect, it will use your current username by default. If you don't have your
own SSH key  in your `authorized_keys` file, you'll need to type your password
(an  tell ansible to ask for it). This is why --ask-pass is used.

Now head to next step with `git checkout step-2` (or click [here](https://github.com/leucos/ansible-tuto/tree/step-2)).

