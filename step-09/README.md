Ansible tutorial
================

Adding another Webserver
-------------------------

We have one web server. Now we want two.

# Updating the inventory

Since we have big expectations, we'll add another web server and a load
balancer we'll configure in the next step. But let's complete the inventory now.

```
[web]
host1.example.org ansible_host=192.168.33.11 ansible_user=root
host2.example.org ansible_host=192.168.33.12 ansible_user=root

[haproxy]
host0.example.org ansible_host=192.168.33.10 ansible_user=root
```

Remember we're specifying `ansible_host` here because the host has a
different IP than expected (or can't be resolved). You could add these hosts
in your `/etc/hosts` and not have to worry, or use real host names (which is
what you would do in a classic situation).

# Building another web server

We didn't do all this work for nothing. Deploying another web server is dead 
simple:

```bash
$ ansible-playbook -i step-09/hosts step-09/apache.yml

PLAY [web] ********************* 

GATHERING FACTS ********************* 
ok: [host2.example.org]
ok: [host1.example.org]

TASK: [Updates apt cache] ********************* 
ok: [host1.example.org]
ok: [host2.example.org]

TASK: [Installs necessary packages] ********************* 
ok: [host1.example.org] => (item=apache2,libapache2-mod-php5,git)
changed: [host2.example.org] => (item=apache2,libapache2-mod-php5,git)

TASK: [Push future default virtual host configuration] ********************* 
ok: [host1.example.org]
changed: [host2.example.org]

TASK: [Activates our virtualhost] ********************* 
changed: [host2.example.org]
changed: [host1.example.org]

TASK: [Check that our config is valid] ********************* 
changed: [host2.example.org]
changed: [host1.example.org]

TASK: [Rolling back - Restoring old default virtualhost] ********************* 
skipping: [host1.example.org]
skipping: [host2.example.org]

TASK: [Rolling back - Removing out virtualhost] ********************* 
skipping: [host1.example.org]
skipping: [host2.example.org]

TASK: [Rolling back - Ending playbook] ********************* 
skipping: [host1.example.org]
skipping: [host2.example.org]

TASK: [Deploy our awesome application] ********************* 
ok: [host1.example.org]
changed: [host2.example.org]

TASK: [Deactivates the default virtualhost] ********************* 
changed: [host1.example.org]
changed: [host2.example.org]

TASK: [Deactivates the default ssl virtualhost] ********************* 
changed: [host2.example.org]
changed: [host1.example.org]

NOTIFIED: [restart apache] ********************* 
changed: [host1.example.org]
changed: [host2.example.org]

PLAY RECAP ********************* 
host1.example.org              : ok=10   changed=5    unreachable=0    failed=0    
host2.example.org              : ok=10   changed=8    unreachable=0    failed=0    
```

All we had to do was remove `-l host1.example.org` from our command line. Remember 
`-l` is a switch that limits the playbook run on specific hosts. Now that we don't 
limit anymore, it will run on all hosts where the playbook is intended to run on 
(i.e. `web`).

If we had other servers in group `web` but wanted to limit the playbook to a subset, 
we could have used, for instance: `-l firsthost:secondhost:...`.

Now that we have this nice farm of web servers, let's turn it into a cluster by 
putting a load balancer in front of them in [step-10](https://github.com/leucos/ansible-tuto/tree/master/step-10).
