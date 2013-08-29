Ansible tutorial
================

To make the tutorial self-contained, a Vagrant file is provided. Vagrant makes
it easy to bootstrap barebones virtual machines with VirtualBox.

# Installing Vagrant

In order to run Vagrant, you need :

- VirtualBox installed
- Ruby installed (should be on your system already)
- Vagrant 1.1+ installed (see
  http://docs.vagrantup.com/v2/installation/index.html).

This should be all it takes to set up Vagrant.

Now bootstrap your virtual machines with :

`vagrant up`

and go grab yourself a coffee (note that if you use vagrant-hostmaster, you'll need 
to type your password since it needs to sudo as root).

If something goes wrong, refer to Vagrant's [Getting Started
Guide](http://docs.vagrantup.com/v2/getting-started/index.html).

# SSH keys on the virtual machines

Vagrant installs an key for SSH automatically. To use this key during the tutorial add it to your ssh-agent:

    ssh-add ~/.vagrant.d/insecure_private_key
Identity added: .../.vagrant.d/insecure_private_key (.../.vagrant.d/insecure_private_key)

Now head to the first step in `./step-01` (or click
[here](https://github.com/leucos/ansible-tuto/tree/master/step-01)).

