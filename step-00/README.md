Ansible tutorial
================

To make the tutorial self-contained, a Vagrant file is provided. Vagrant makes
it easy to bootstrap barebones virtual machines with VirtualBox.

# Installing Vagrant

In order to run Vagrant, you nedd :

- VirtualBox installed
- Ruby installed (should be on your system already)
- Vagrant gem installed :

    gem install vagrant

- Vagrant host master gem installed

    vagrant gem install vagrant-hostmaster

This should be all it takes to set up Vagrant.

Now bootstrap your virtual machines with :

    vagrant up

and go grab yourself a coffee (note that if you use vagrant-hostmaster, you'll need 
to type your password since it needs to sudo as root).

If something goes wrong, refer to Vagrant's [Getting Started Guide](http://docs-v1.vagrantup.com/v1/docs/getting-started/index.html).

# Adding your SSH keys on the virtual machines

To follow this tutorial, you'll need to have your keys in VMs root's `authorized_keys`. 
While this is not absolutely necessary (Ansible can use sudo, password authentication, 
etc...), it will make things way easier.

Ansible is perfect for this and we will use it for the job. However I won't
explain what's happening for now. Just trust me.

    ansible-playbook -i step-00/hosts step-00/setup.yml --ask-pass --sudo

When asked for password, enter _vagrant_.

To polish things up, it's better to have an ssh-agent running, and add your keys 
to it (`ssh-add`).

Now head to the first step in `./step-01` (or click
[here](https://github.com/leucos/ansible-tuto/tree/master/step-01)).