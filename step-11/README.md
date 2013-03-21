Ansible tutorial
================

Variables again
---------------

So we've set-up our loadbalancer, and it works quite well. We grabbed variables from 
facts and used them to buid the configuration. But Ansible also supports other kinds 
of variables. We already saw `ansible_ssh_host` in inventory, but now we'll use variables 
defined in `host_vars` and `group_vars` files. 

# Fine tuning our HAProxy configuration

HAProxy usually checks if the backends are alive. When a backend seems dead, it is 
removed from the backend pool and HAproxy doesn't sends requests anymore to it.

Backends can also have different weights (between 0 and 256). The higher the weight, 
the higher number of connections the backend will receive compared to other backends.
It's usefull to spread traffic more appropriately if nodes are not equally powerful.

We'll use variables to configure all theese parameters.

# Group vars

The check interval will be set in a group_vars file for haproxy. This will ensure 
all haproxies will inherit from it.

We just need to create the file `group_vars/haproxy` below the inventory
directory. The file has to be named after the group you want to define the
variables for. If we wanted to define variables for the web group, the file
would be names `group_vars/web`.

    haproxy_check_interval: 3000

The name is arbitrary. Meaningful names are recommended of course, but there is no 
required syntax. You could even use complex variables (a.k.a. Python dict) like this:

    haproxy:
        check_interval: 3000

This is just a matter of taste. Complex vars can help group stuff logically. They 
can also, under some circumstances, merge subsequently defined keys (note however 
that this is not the default ansible behaviour). For now we'll just use simple variables.

# Hosts vars

Hosts vars follow exactly the same rules, but live in files under `host_vars` directory.

Let's define weights for our backends in `host_vars/host1.example.com`:


    haproxy_backend_weight: 100

and `host_vars/host2.example.com`:

    haproxy_backend_weight: 150

If we'd define `haproxy_backend_weight` in `group_vars/web`, if would be used as a 'default': 
variables defined in `host_vars` files overrides varibles defined in `group_vars`. 

# Updating the template

The template must be updated to use these variables.

    listen cluster
        bind {{ ansible_eth1['ipv4']['address'] }}:80
        mode http
        stats enable
        balance roundrobin
    {% for backend in groups['web'] %}
        server {{ hostvars[backend]['ansible_hostname'] }} {{ hostvars[backend]['ansible_eth1']['ipv4']['address'] }} check inter {{ haproxy_check_interval }} weight {{ hostvars[backend]['haproxy_backend_weight'] }} port 80
    {% endfor %}
        option httpchk HEAD /index.php HTTP/1.0

Let's go :

    ansible-playbook -i step-11/hosts step-11/haproxy.yml

Note that, while we could, it's not necessary to run the apache playbook since nothing 
changed, but we had to cheat a bit for that. Here is the updated haproxy playbook 
:

    - hosts: web
      tasks: 
        - name : Fake task to gather facts
          action: debug msg="done"
          
    - hosts: haproxy
      tasks:
        - name: Installs haproxy load balancer
          action: apt pkg=haproxy state=installed update_cache=yes

        - name: Pushes configuration
          action: template src=templates/haproxy.cfg.j2 dest=/etc/haproxy/haproxy.cfg mode=0640 owner=root group=root
          notify:
            - restart haproxy

        - name: Sets default starting flag to 1
          action: lineinfile dest=/etc/default/haproxy regexp="^ENABLED" line="ENABLED=1"
          notify:
            - restart haproxy 

      handlers:
        - name: restart haproxy
          action: service name=haproxy state=restarted

See? We added a play for web hosts at the top. It does nothing. But it's here because 
it will trigger facts gathering on hosts in group `web`. This is required because 
the haproxy playbook needs to pick facts from hosts in this group. If we don't do 
this, ansible will complain saying that `ansible_eth1` key doesn't exist.

At this point, you can try building up everything from scratch, to see if you can 
properly provision your cluster with your playbook.

Fire in the hole!

    vagrant destroy -f
    vagrant up
    ansible-playbook -i step-00/hosts step-00/setup.yml --ask-pass --sudo

All the preceeding commands are just here to set-up our test environment. Deploying 
on the blank machines just requires one line :

    ansible-playbook -i step-11/hosts step-11/apache.yml step-11/haproxy.yml

Just one command to rule them all: you have your cluster, can add nodes ad
nauseam, tune settings, ... all this can be extended at will with more variables, 
other plays, etc...

# The end

Ok, seems we're done with our tutorial. Hope you enjoyed playing with Ansible, and 
felt the power of this new tool.

Now go straight to [Ansible website](http://ansible.cc), dive in the docs, check references, 
skim through playbooks, chat on freenode in #ansible, and foremost, have fun!
