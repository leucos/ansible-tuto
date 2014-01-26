Ansible tutorial
================

Talking with nodes
------------------

Now we're good to go. Let's play with the command we saw in the previous chapter: 
`ansible`. This command is the first one of three that ansible provides which interact 
with nodes.

# Doing something useful

In the previous command, `-m ping` means "use module _ping_". This module is
one of many available with ansible. `ping` module is really simple, it doesn't need any arguments.
Modules that take arguments pass them via `-a` switch. Let's see a few other modules.

## Shell module

This module lets you execute a shell command on the remote host:

    ansible -i step-02/hosts -m shell -a 'uname -a' host0.example.org

Output should look like:

    host0.example.org | success | rc=0 >>
    Linux host0.example.org 3.2.0-23-generic-pae #36-Ubuntu SMP Tue Apr 10 22:19:09 UTC 2012 i686 i686 i386 GNU/Linux

Easy!

## Copy module

No surprise, with this module you can copy a file from the controlling machine to 
the node. Lets say we want to copy our `/etc/motd` to `/tmp` of our target node:

    ansible -i step-02/hosts -m copy -a 'src=/etc/motd dest=/tmp/' host0.example.org

Output should look similar to:

    host0.example.org | success >> {
        "changed": true, 
        "dest": "/tmp/motd", 
        "group": "root", 
        "md5sum": "d41d8cd98f00b204e9800998ecf8427e", 
        "mode": "0644", 
        "owner": "root", 
        "size": 0, 
        "src": "/root/.ansible/tmp/ansible-1362910475.9-246937081757218/motd", 
        "state": "file"
    }

Ansible (more accurately _copy_ module executed on the node) replied back a bunch of 
useful information in JSON format. We'll see how that can be used later.

We'll see other useful modules below. Ansible has a huge 
[module list](http://ansible.cc/docs/modules.html) that covers almost anything you
can do on a system. If you can't find the right module, writing one is pretty
easy (it doesn't even have to be Python, it just needs to speak JSON).

# Many hosts, same command

Ok, the above stuff is fun, but we have many nodes to manage. Let's try that on
other hosts too.

Lets say we want to know which Ubuntu version we have deployed on nodes,
it's pretty easy:

    ansible -i step-02/hosts -m shell -a 'grep DISTRIB_RELEASE /etc/lsb-release' all

`all` is a shortcut meaning 'all hosts found in inventory file'. It would
return:

    host1.example.org | success | rc=0 >>
    DISTRIB_RELEASE=12.04

    host2.example.org | success | rc=0 >>
    DISTRIB_RELEASE=12.04

    host0.example.org | success | rc=0 >>
    DISTRIB_RELEASE=12.04

# More facts

Speaking about node facts, there is another really handy module (weirdly)
called `setup`: it specializes in node's _facts_ gathering.

Try it out:

    ansible -i step-02/hosts -m setup host0.example.org

replies with lots of information:

    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.0.60"
        ], 
        "ansible_all_ipv6_addresses": [], 
        "ansible_architecture": "x86_64", 
        "ansible_bios_date": "01/01/2007", 
        "ansible_bios_version": "Bochs"
        },
        ---snip---
        "ansible_virtualization_role": "guest", 
        "ansible_virtualization_type": "kvm"
    }, 
    "changed": false, 
    "verbose_override": true

It's been truncated for brevity, but you can find many interesting bits in the returned 
data. You may also filter returned keys, in case you're looking for something specific.

For instance, let's say you want to know how much memory you have on all your hosts, 
easy with `ansible -i step-02/hosts -m setup -a 'filter=ansible_memtotal_mb' all`:

    host2.example.org | success >> {
        "ansible_facts": {
            "ansible_memtotal_mb": 187
        }, 
        "changed": false, 
        "verbose_override": true
    }

    host1.example.org | success >> {
        "ansible_facts": {
            "ansible_memtotal_mb": 187
        }, 
        "changed": false, 
        "verbose_override": true
    }

    host0.example.org | success >> {
        "ansible_facts": {
            "ansible_memtotal_mb": 187
        }, 
        "changed": false, 
        "verbose_override": true
    }

Notice that hosts replied in different order compared to the previous output. This 
is because ansible parallelizes communications with hosts!

BTW, when using the setup module, you can use `*` in the `filter=` expression.
It will act like a shell glob.

# Selecting hosts

We saw that `all` means 'all hosts', but ansible provides a 
[lot of other ways to select hosts](http://ansible.cc/docs/patterns.html#selecting-targets):

- `host0.example.org:host1.example.org` would run on host0.example.org and
  host1.example.org
- `host*.example.org` would run on all hosts starting with 'host' and ending with 
'.example.org' (just like a shell glob too)

There are other ways that involve groups, we'll see that in 
[step-03](https://github.com/leucos/ansible-tuto/tree/master/step-03).


