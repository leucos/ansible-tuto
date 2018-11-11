# Ansible tutorial: Ansible playbooks

Playbook concept is very simple: it's just a series of ansible commands
(tasks), like the ones we used with the `ansible` CLI tool. These tasks are
targeted at a specific set of hosts/groups.

The necessary files for this step should have appeared magically and you don't
even have to type them.

## Apache example (a.k.a. Ansible's "Hello World!")

We assume we have the following inventory file (let's name it `hosts`):

```ini
[web]
host1
```

and all hosts are debian-like.

Note: remember you can (and in our exercise we do) use `ansible_host` to set
the real IP of the host. You can also change the inventory and use a real
hostname. In any case, use a non-critical machine to play with! In the real
hosts file, we also have `ansible_user=root` to cope with potential different
ansible default configurations.

Lets build a playbook that will install apache on machines in the `web` group.

```yaml
- hosts: web
  tasks:
    - name: Installs apache web server
      apt:
        pkg: apache2
        state: present
        update_cache: true
```

We just need to say what we want to do using the right ansible modules. Here,
we're using the [apt](http://docs.ansible.com/apt_module.html) module that can
install debian packages. We also ask this module to update the package cache.

We also added a name for this task. While this is not necessary, it's very
informative when the playbook runs, so it's highly recommended.

All in all, this was quite easy!

You can run the playbook (lets call it `apache.yml`):

```bash
ansible-playbook -i step-04/hosts -l host1 step-04/apache.yml
```

Here, `step-04/hosts` is the inventory file, `-l` limits the run only to
`host1` and `apache.yml` is our playbook.

When you run the above command, you should see something like:

```bash
PLAY [web] *********************

GATHERING FACTS *********************
ok: [host1]

TASK: [Installs apache web server] *********************
changed: [host1]

PLAY RECAP *********************
host1              : ok=2    changed=1    unreachable=0    failed=0
```

Note: You might see a cow passing by if you have `cowsay` installed. You can
get rid of it with `export ANSIBLE_NOCOWS="1"` if you don't like it.

Let's analyse the output one line at a time.

```bash
PLAY [web] *********************
```

Ansible tells us it's running the play on hosts `web`. A play is a suite of
ansible instructions related to a host. If we'd have another `-host: blah` line
in our playbook, it would show up too (but after the first play has completed).

```bash
GATHERING FACTS *********************
ok: [host1]
```

Remember when we used the `setup` module? Before each play, ansible runs it on
necessary hosts to gather facts. If this is not required because you don't need
any info from the host, you can just add `gather_facts: no` below the host
entry (same level as `tasks:`).

```bash
TASK: [Installs apache web server] *********************
changed: [host1]
```

Next, the real stuff: our (first and only) task is run, and because it says
`changed`, we know that it changed something on `host1`.

```bash
PLAY RECAP *********************
host1              : ok=2    changed=1    unreachable=0    failed=0
```

Finally, ansible outputs a recap of what happened: two tasks have been run and
one of them changed something on the host (our apache task, setup module
doesn't change anything).

Now let's try to run it again and see what happens:

```bash
$ ansible-playbook -i step-04/hosts -l host1 step-04/apache.yml

PLAY [web] *********************

GATHERING FACTS *********************
ok: [host1]

TASK: [Installs apache web server] *********************
ok: [host1]

PLAY RECAP *********************
host1              : ok=2    changed=0    unreachable=0    failed=0
```

Now changed is '0'. This is absolutely normal and is one of the core feature of
ansible: the playbook will act only if there is something to do. It's called
_idempotency_, and means that you can run your playbook as many times as you
want, you will always end up in the same state (well, unless you do crazy
things with the `shell` module of course, but this is beyond ansible's
control).

## Refining things

Sure our playbook can install apache server, but it could be a bit more
complete. It could add a virtualhost, ensure apache is restarted. It could
even deploy our web site from a git repository. Lets "[make it so][]"

Head to next step in
[step-05](https://github.com/leucos/ansible-tuto/tree/master/step-05).

[make it so]: https://www.google.fr/search?q=Michael+DeHaan+%22make+it+so%22 "© Michael DeHaan"
