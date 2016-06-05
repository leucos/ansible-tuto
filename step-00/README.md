Ansible tutorial
================

To make the tutorial self-contained, a Vagrant file is provided. Vagrant makes
it easy to bootstrap barebones virtual machines with VirtualBox.

# Installing Vagrant

In order to run Vagrant, you need:

- VirtualBox installed
- Ruby installed (should be on your system already)
- Vagrant 1.1+ installed (see
  http://docs.vagrantup.com/v2/installation/index.html).

This should be all it takes to set up Vagrant.

Now bootstrap your virtual machines with the following command. Note that you do
not need to download any "box" manually. This tutorial already includes a
`Vagrantfile` to get you up and running, and will get one for you if needed.

`vagrant up`

and go grab yourself a coffee (note that if you use vagrant-hostmaster, you'll need 
to type your password since it needs to sudo as root).

If something goes wrong, refer to Vagrant's [Getting Started
Guide](http://docs.vagrantup.com/v2/getting-started/index.html).

## Cautionary tale about NetworkManager

On some systems, NetworkManager will take over `vboxnet` interfaces and mess
everything up. If you're in this case, you should prevent NetworkManager from
trying to autoconfigure `vboxnet` interfaces. Just edit
`/etc/NetworkManager/NetworkManager.conf` (or whatever the NetworkManager config
is on your system) and add in section `[keyfile]`:

    unmanaged-devices=mac:MAC_OF_VBOXNET0_IF;mac:MAC_OF_VBOXNET1_IF;...

Then destroy Vagrant machines, restart NetworkManager and try again.

# Adding your SSH keys on the virtual machines

To follow this tutorial, you'll need to have your keys in VMs root's `authorized_keys`. 
While this is not absolutely necessary (Ansible can use sudo, password authentication, 
etc...), it will make things way easier.

Ansible is perfect for this and we will use it for the job. However I won't
explain what's happening for now. Just trust me.

```bash
ansible-playbook -c paramiko -i step-00/hosts step-00/setup.yml --ask-pass --become
```


When asked for password, enter _vagrant_. If you get "Connections refused" errors, please check the firewall settings of your machine.

To polish things up, it's better to have an ssh-agent running, and add your keys 
to it (`ssh-add`).

**NOTE:** We are assuming that you're using Ansible version v2 on your local machine. If not you should upgrade ansible to v2 before using this repository

To check your ansible version use the command `ansible --version`. The output should be similar to the above:

    $ ansible --version
      ansible 2.0.0.2
        config file = /etc/ansible/ansible.cfg
        configured module search path = Default w/o overrides

Now head to the first step in [step-01](https://github.com/leucos/ansible-tuto/tree/master/step-01).

