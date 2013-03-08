Ansible tutorial
================

Talking with nodes
------------------

Now we're good to go, les play with the command we saw in the previous chapter : 
`ansible`. This command is the first of the three ansible provides that interacts 
with nodes.

# Checking host is reachable

If you have access to a machine with you current key, you can test if ansible
can  talk to it by using the command showned previously. Let's say we want to
manage `host0.example.org`, we first need to add this host to our inventory file :

    echo "host0.example.com" >> ~/hosts

Now :

    ansible -m ping host0.example.com

If you need to use another user name on the remote host, you can specify it with 
`-u` :

    ansible -m ping host0.example.com -u root

Since we're going to do a lot of stuff as root, we'll set this as the default,
using `ANSIBLE_REMOTE_USER` environment variable :

    export ANSIBLE_REMOTE_USER=root

Don't worry, we'll use a config file later so we don't have to set those variables.

# Doing something useful

In the above command, the `-m ping` means "use module 'ping'". This module is
one  of many modules available with ansible. `ping` module is really simple :
it doesn't take any argument. Most modules take arguments, passed via the
`-a` switch. Let's see a few modules.

## Shell module

This module let's you execute a shell command on the remote host :


    ansible -m shell -a 'uname -a' host0.example.com

might reply :
  
    host0.example.com | success | rc=0 >>
    Linux host0.example.com 2.6.32-28-generic-pae #55-Ubuntu SMP Mon Jan 10 22:34:08 UTC 2011 i686 GNU/Linux

Easy !

## Copy module

No surprise, with this module you can copy a file from the controlling machine to 
the node. Let's say we want to copy our `/etc/hosts` in `/tmp` of our target node :

    ansible -m copy -a 'src=/etc/hosts dest=/tmp/' host0.example.com

might reply :

    host0.example.com | success >> {
        "changed": true, 
        "dest": "/tmp/hosts", 
        "group": "root", 
        "md5sum": "fa676fd2ef2ecf37f50ffd2bc57b79ae", 
        "mode": "0644", 
        "owner": "root", 
        "size": 409, 
        "src": "/root/.ansible/tmp/ansible-1362580394.39-32669960647560/hosts", 
        "state": "file"
    }

Ansibles (in fact, the copy module executed on the node) replies back a bunch of 
useful information (in JSON actually). We'll see how that can be used later.

We'll see other useful modules below. Ansible has a huge [module
list](http://ansible.cc/docs/modules.html) that covers almost anything you
can do on a system. If you can't find the right module,  writing one is pretty
easy (it doesn't even have to be python, it just needs to speak  JSON).

# Many hosts, same command

Ok, the above stuff is fun, but we have node_s_ to manage. Let's add few
others in our inventory :

    echo -e "host1.example.com\nhost2.example.com" >> ~/hosts

Now, if we want to know which Ubuntu version we have deployed on the nodes,
it's pretty easy :

    ansible -m shell -a 'cat /etc/lsb-release' all

`all is a shortcut meaning 'all hosts found in inventory file'. It would
return :

    host0.example.com | success | rc=0 >>
    DISTRIB_ID=Ubuntu
    DISTRIB_RELEASE=12.04
    DISTRIB_CODENAME=precise
    DISTRIB_DESCRIPTION="Ubuntu 12.04.2 LTS"

    host1.example.com | success | rc=0 >>
    DISTRIB_ID=Ubuntu
    DISTRIB_RELEASE=10.04
    DISTRIB_CODENAME=lucid
    DISTRIB_DESCRIPTION="Ubuntu 10.04.4 LTS"

    host2.example.com | success | rc=0 >>
    DISTRIB_ID=Ubuntu
    DISTRIB_RELEASE=12.04
    DISTRIB_CODENAME=precise
    DISTRIB_DESCRIPTION="Ubuntu 12.04.1 LTS"

# Moar facts

Speaking about node facts, there is another really handy module (weirdly)
called `setup` : it specializes in nodes _facts_ gathering.

Try it up :

    ansible -m setup host0.example.com

replies with lots of information :

    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.0.60"
        ], 
        "ansible_all_ipv6_addresses": [], 
        "ansible_architecture": "x86_64", 
        "ansible_bios_date": "01/01/2007", 
        "ansible_bios_version": "Bochs"
        }, 
        ...
        "ansible_virtualization_role": "guest", 
        "ansible_virtualization_type": "kvm"
    }, 
    "changed": false, 
    "verbose_override": true

It's been truncated for brevity, but you can find many interesting bits in the returned 
data. You may also filter returned keys, in case you're looking for something specific.

For instance, let's say you want to know how much memory you have on all your hosts, 
easy :

    $ ansible -m setup -a 'filter=ansible_memtotal_mb' all
    host0.example.com | success >> {
        "ansible_facts": {
            "ansible_memtotal_mb": 2012
        }, 
        "changed": false, 
        "verbose_override": true
    }

    host1.example.com | success >> {
        "ansible_facts": {
            "ansible_memtotal_mb": 3023
        }, 
        "changed": false, 
        "verbose_override": true
    }

    host2.example.com | success >> {
        "ansible_facts": {
            "ansible_memtotal_mb": 491
        }, 
        "changed": false, 
        "verbose_override": true
    }

If you use `*` in the `filter=` expression, it will act like a shell glob.

# Selecting hosts

We saw that `all` means 'all hosts', but ansible provides a [lot of other ways to 
select hosts](http://ansible.cc/docs/patterns.html#selecting-targets) :

- host0.example.com:host1.example.com would run on host0.example.com and
  host1.example.com
- host*.example.com would run on all hosts starting with 'host' and ending with 
'.example.com' (just like a shell glob too)

There are other ways that involve groups, we'll see that in the [next
step](https://github.com/leucos/ansible-tuto/tree/step-3).

Now head to next step with `git checkout step-3` (or click above).

