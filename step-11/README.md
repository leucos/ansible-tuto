# Ansible tutorial: Variables again

So we've setup our loadbalancer, and it works quite well. We grabbed variables
from facts and used them to build the configuration. But Ansible also supports
other kinds of variables. We already saw `ansible_host` in inventory, but now
we'll use variables defined in `host_vars` and `group_vars` files.

## Fine tuning our HAProxy configuration

HAProxy usually checks if the backends are alive. When a backend seems dead, it
is removed from the backend pool and HAproxy doesn't send requests to it
anymore.

Backends can also have different weights (between 0 and 256). The higher the
weight, the higher number of connections the backend will receive compared to
other backends. It's useful to spread traffic more appropriately if nodes are
not equally powerful.

We'll use variables to configure all these parameters.

## Group vars

The check interval will be set in a group_vars file for haproxy. This will
ensure all haproxies will inherit from it.

We just need to create the file `group_vars/haproxy.yml` below the inventory
directory. The file has to be named after the group you want to define the
variables for. If we wanted to define variables for the web group, the file
would be named `group_vars/web.yml`.

Note that the `.yml` is optionalm: we could name haproxy group vars file
`group_vars/haproxy` and Ansible would be ok with it. The extension just helps
editors picking the right syntax highlighter.

```jinja
haproxy_check_interval: 3000
haproxy_stats_socket: /tmp/sock
```

The name is arbitrary. Meaningful names are recommended of course, but there is
no required syntax. You could even use complex variables (a.k.a. Python dict)
like this:

```yaml
haproxy:
    check_interval: 3000
    stats_socket: /tmp/sock
```

This is just a matter of taste. Complex vars can help group stuff logically.
They can also, under some circumstances, merge subsequently defined keys (note
however that this is not the default ansible behaviour). For now we'll just use
simple variables.

## Hosts vars

Hosts vars follow exactly the same rules, but live in files under `host_vars`
directory.

Let's define weights for our backends in `host_vars/host1.example.com`:

```ini
haproxy_backend_weight: 100
```

and `host_vars/host2.example.com`:

```ini
haproxy_backend_weight: 150
```

If we'd define `haproxy_backend_weight` in `group_vars/web`, it would be used
as a 'default': variables defined in `host_vars` files overrides variables
defined in `group_vars`.

## Updating the template

The template must be updated to use these variables.

```jinja
global
    daemon
    maxconn 256
{% if haproxy_stats_socket %}
    stats socket {{ haproxy_stats_socket }}
{% endif %}

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

listen cluster
    bind {{ ansible_all_ipv4_addresses.1 }}:80
    mode http
    stats enable
    balance roundrobin
{% for backend in groups['web'] %}
    server {{ hostvars[backend]['ansible_hostname'] }} {{ hostvars[backend].ansible_all_ipv4_addresses.1 }} check port 80
{% endfor %}
    option httpchk HEAD /index.php HTTP/1.0
```

Note that we also introduced an `{% if ...` block. This block enclosed
will only be rendered if the test is true. So if we define
`haproxy_stats_socket` somewhere for our loadbalancer (we might even use the
`--extra-vars="haproxy_stats_sockets=/tmp/sock"` at the command line), the enclosed
line will appear in the generated configuration file (note that the
suggested setup is highly insecure!).

Let's go:

```bash
ansible-playbook -i step-11/hosts step-11/haproxy.yml
```

Note that, while we could, it's not necessary to run the apache playbook since
nothing changed, but we had to cheat a bit for that. Here is the updated
haproxy playbook:

```yaml
- hosts: web
  gather_facts: true

- hosts: haproxy
  tasks:
    - name: Installs haproxy load balancer
      apt:
        pkg: haproxy
        state: present
        update_cache: yes

    - name: Pushes configuration
      template:
        src: templates/haproxy.cfg.j2
        dest: /etc/haproxy/haproxy.cfg
        mode: 0640
        owner: root
        group: root
      notify:
        - restart haproxy

    - name: Sets default starting flag to 1
      lineinfile:
        dest: /etc/default/haproxy
        regexp: "^ENABLED"
        line: "ENABLED=1"
      notify:
        - restart haproxy

  handlers:
    - name: restart haproxy
      service:
        name: haproxy
        state: restarted
```

See? We added an empty play for web hosts at the top. It does nothing except
`gather_facts: true`. But it's here because it will trigger facts gathering on
hosts in group `web`.  This is required because the haproxy playbook needs to
pick facts from hosts in this group. If we don't do this, ansible will complain
saying that `ansible_all_ipv4_addresses` key doesn't exist.

Note that we already did that in the previous step, but we did not mention it.

Now on to the next chapter about "Migrating to Roles!", in
[step-12](https://github.com/leucos/ansible-tuto/tree/master/step-12).
