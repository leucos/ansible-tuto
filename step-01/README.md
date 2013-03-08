Ansible tutorial
================

# Inventory

Before continuing, you need an inventory file. The default place for such a
file is  `/etc/ansible/hosts`. However, you can configure ansible to look
somewhere else, use an environment variable, or use the `-i` flag in ansible
commands an provide the inventory path.

For now, we'll create an inventory file in our home dir and use an environment
variable :

    echo "localhost" > hosts
    export ANSIBLE_HOSTS=`pwd`/hosts

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

Now head to next step in directory `./step-02` (or click
[here](https://github.com/leucos/ansible-tuto/tree/master/step-02)).

