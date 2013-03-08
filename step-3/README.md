Ansible tutorial
================

Grouping hosts
--------------

Hosts in inventory can be grouped arbitrarily. For instance, you could have a `debian` 
group, a `web-servers` group, a `production` group, etc...

    [debian]
    host0.example.org
    host1.example.org
    host2.example.org

This can even be expressed shorter :

    [debian]
    host[0-2].example.org

If you wish to use child groups, just define a `[groupname:children]` and add child 
groups in it.
For instance, let's say we have various flavors of linux running, we could organize 
our inventory like this :

    [ubuntu]
    host0.example.org

    [debian]
    host[1-2].example.org

    [linux:children]
    ubuntu
    debian

Grouping of course, leverages configuration mutualization.

Setting variables
-----------------

You can set variables to hosts in several places : inventory file, host vars
files, group vars files, etc...

I usually set most of my variables in group/host vars files (more on that later). 
However, I often use some variables directly in the inventory file, like `ansible_ssh_host` 
which sets the IP address for the host. Ansible, by defaults, resolves the host name 
when it attempts to connect via SSH. But when you're bootstrapping a host, it might 
not have it's definitive ip address. `ansible_ssh_host` comes handy here.

Variables can also be set at command line with `--extra-vars` (or `-e`)
switch when using `ansible-playbook` (but not  with the `ansible` command).

`ansible_ssh_post`, as you can guess, has the same function regarding ssh port ansible 
will try to connect to.

    [ubuntu]
    host0.exxample.org ansible_ssh_host=192.168.0.12 ansible_ssh_port=2222

Ansible will look for additional variables definitions in group and host variable 
files. These files will be searched in directories `group_vars` and `host_vars`, 
below the directory where the main inventory file is located.

The files will be searched by name. For instance, using the last inventory file we've 
made above, `host0.example.org` variables will be searched in those files :

- `group_vars/linux`
- `group_vars/ubuntu`
- `host_vars/host0.example.org`

It doesn't matter if those files do not exist, but if they do, ansible will use them.

Now that we know the basics of modules, inventories and variables, let's
explore the real power of Ansible with playbooks.

Head to next step with `git checkout step-4` (or click
[here](https://github.com/leucos/ansible-tuto/tree/step-4)).

