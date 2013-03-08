Ansible tutorial
================

Templates
---------

We'll use the `haproxy` as loadbalancer. Of course, install is just like we
did for apache. But now configuration is a bit more tricky since we need to list 
all web servers in haproxy's configuration. How can we do that ?

# HAProxy configuration template

Ansible uses [Jinja2](http://jinja.pocoo.org/docs/), a templating engine for Python. 
When you write Jinja2 templates, you can use any variable defined by Ansible.

For instance, if you want to output the inventory_name of the host the template is 
currently built for, you just can write `{{ inventory_hostname }}` in the Jinja template.

Or if you need the IP of the first ethernet interface (which ansible knows thanks 
to the `setup` module), you just write : `{{ ansible_eth0']['ipv4']['address'] }}` 
in your template.

Jinja2 templates also support conditionals, for-loops, etc...

Let's make a `templates/` directory and create a Jinja template inside. We'll
call  it `haproxy.cfg.j2`. We use the `.j2` extension by convention, to make
it obvious that this  is a Jinja2 template, but this is by no means
necessary.

    listen cluster
        bind {{ ansible_default_ipv4['address'] }}
        mode http
    {% if admin_socket %}
        stats socket /etc/haproxy/haproxysock level admin
    {% endif %}
        balance roundrobin
    {% for backend in groups['web'] %}
        server {{ hostvars[backend]['ansible_hostname'] }} {{ hostvars[backend]['ansible_eth0']['ipv4']['address'] }} cookie {{ hostvars[backend]['ansible_hostname'] }} check port 80
    {% endfor %}
        option httpchk HEAD /index.php HTTP/1.0

We have many new things going on here. 

First, `{{ ansible_default_ipv4['address'] }}` will be replaced by the _default_ 
IP of the load balancer. The default IP address is in fact the first. For more control 
on which interface we start the listener, we could have used `ansible_eth0['ipv4']['address']`.

Then, we have an `{% if ...` block. This block will only be rendered if the test 
is true. So if we define `admin_socket` somewhere for our loadbalancer (we might 
even use the `--extra-vars="admin_socket=True"` at the command line), the enclosed 
line will appear in the generated configuration file.

Finally, we have a loop. This loop is used to build the backend servers list.
It will loop over every host listed in the `[web]` group (and put this host in the 
`backend` variable). For each of the hosts it will render a line, using host's facts. 
All hosts facts are exposed in the `hostvars` variable, so it's easy to access another 
host variables (like it's hostname or IP in this case)..

We could have written the host list by hand, since we have only 2 of them. But
we're hoping that the server will be very successful, and that we'll need a
hundred of them. Thus, adding servers to the configuration or swapping some
out boils donw to adding or removing hosts from the `[web]` group. 

# HAProxy playbook

We've done the most difficult part of the job. Writing a playbook to install and 
configure HAproxy is a breeze :

    - hosts: haproxy
      tasks:
        - name: Installs haproxy load balancer
          action: apt pkg=haproxy state=installed

        - name: Pushes configuration
          action: template src=templates/haproxy.cfg.j2 dest=/etc/haproxy/haproxy.cfg mode=0640 owner=root group=root
          notify:
            - restart haproxy

      handlers:
        - name: restart haproxy
          action: service name=haproxy state=restarted

Sounds familiar no ? The only new module here is `template`, which has the same arguments 
as `copy`. We also restrict this playbook to the group `haproxy`.

And now... let's try this out. Since our inventory contains only hosts
necessary for the cluster, we don't need to limit the host list, and can even
run both playbooks (which is not really necessary, since we didn't make any changes 
to the apache.yml config, but we just want to be sure everythingis fine) :

    $ ansible-playbook -i hosts step-10/apache.yml step-10/haproxy.yml

    # TBC

[step-11](https://github.com/leucos/ansible-tuto/tree/master/step-11)).
