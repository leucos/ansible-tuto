Ansible tutorial
================

# Building firewall rules

We'll have a bunch of work now, and a few roles to write in this
chapter. We want to secure our ssh config, and add firewall rules.
For instance, we want to avoid people trying to ssh to our servers and
change few things in our ssh servers config. We also want to avoid
browsers to hit our backend servers directly.

For this, we will write two new roles : a ssh role and and iptables
role. So this part will be a bit longer that the previous ones, and will
span several steps. Grab some coffee, here we go.

## Writing the ssh server role

In the last chapter, I said I didn't like to set vars in role's
`vars/main.yml`. However, that's not exactly true.

While vars often depend on the server being acted on, you sometimes need
sane defaults.  Of course, these defaults could be set in the
`group_vars\all` file which holds variables pertaining to all servers.
Note that if you set a variable in `group_vars/somegroup` or
`host_vars\somehost`, it will override role's var value.
So it's much easier to write defaults in role's var files, especially if
you want to share your roles: this way, your role will come with default
settings.

For the ssh server role, our structure will look like this :

    roles
      |
      |_sshd
           |
           |_templates
           |   |
           |   |_sshd_config.j2   _ssh server config file)_
           |
           |_tasks
           |   |
           |   |_main.yml         _just a task to deploy the config file_
           |
           |_handlers
           |   |
           |   |_main.yml         _a restart handler if needed_
           |
           |_vars
               |
               |_main.yml         _some defaults_

### The template

For brevity, I won't include the whole `sshd_config.j2` template, but
just review the lines that contains variables :

    # {{ ansible_managed }}

This cool variable will be replaced by a tag containing something like :

    Ansible managed: /home/user/.../roles/sshd/templates/shd_config.j2 modified on 2013-07-03 14:16:23 by user on userhost

This is nice since it alerts people watching the file that it's managed
by ansible.

    # What port listen on
    Port {{ ssh_port }}

This will define which port we want sshd to listen on.

    # X11
    X11Forwarding {{ ssh_x11 }}

If we want X11 forwarding (i.e. the ability to run X applications on the
remote host and display them on our machine), we can set this variable
to "yes".

    AllowUsers {% if 'vagrant' in group_names -%} vagrant {% endif -%} {% for adm in ssh_allow_users -%} {{ adm }} {% endfor -%}


This one is a bit more complex : we restrict the user accounts that are allowed to be
accessed via ssh. This is tricky since we have to stuff everything one
one line (sshd is very strict about this).
 But if we split up the parts, we have :

`{% if 'vagrant' in group_names -%} vagrant {% endif -%}` will just echo
"vagrant" if the machine being processed is in the `vagrant` group.
Ansible will figure this out automatically as long as your machine is in
this group.

`{% for adm in ssh_allow_users -%} {{ adm }} {% endfor -%}` will loop
over usernames listed in the `ssh_allow_users` variable, and echo them
here.

For instance, if the machine is in a `vagrant` group, and if it has a
`ssh_allow_users` variable defined like ;

    ssh_allow_users;
      - alice
      - bob

The resulting line will look like :

    AllowUsers vagrant alice bob

### The tasks and handler

On the tasks side, there not a lot :

    - name: Install openssh-server
      apt: name=openssh-server state=latest update_cache=yes
      notify:
        - Restarts sshd
      tags:
        - ssh

    - name: Deploys sshd config
      template: src="../templates/sshd_config.j2" dest=/etc/ssh/sshd_config owner=root group=root mode=0644 backup=yes
      notify:
        - Restarts sshd
      tags:
        - ssh

A few notes though. You might wonder why We have a play that installs
sshd... over ssh ! Yes, that's right, it looks like it's useless.
However, since we use the `state=latest` and `update_cache=yes`, running
this task will update the cache and install a never `openssh-server`
version if available.

The second task will use our previously mentioned template and push it in
sshd config directory. If you have some experience with Ansible, you
might be wondering why I used `src="../templates/sshd_config.j2"`.
Indeed, Ansible is much more clever than that : when using the
`template` module, it will look automatically in the `template/`
directory. Similarly, the `copy` module will hunt files from `files\`.
However, `vim` being my editor of choise, using the path relative to the
current file will let me hit `gf` on the template and open the file
directly. But I digress...

Both tasks will trigger a sshd restart if they are return with a
`changed` status, and the handler is as simple as it can be:

    - name: Restarts sshd
      service: name=ssh state=restarted

### Variables

Remerber that the role's variables have the lowest precedence. So if we
set the same variables somewhere else (host_vars files,
group_vars_files, command line), they will be overriden. We'll use this
at our advantage to write some sane defaults values for the role.

    ssh_port: 22
    ssh_x11: "no"
    ssh_allow_users:
      - root

Yes, one might argue that `root` isn't a very sane default. However,
_sane_ doesn't mean _secure_: we just want our template to be filled
properly and don't want sshd to choke !
We could have done this better, using the rollback paradigm we wrote for 
in
[step-07](https://github.com/leucos/ansible-tuto/tree/master/step-07),
but this is left as an exercise for the reader since we already have a
lot of things to stuff in this chapter.

## The iptables role

_Disclaimer : while what we're about to write is a good start, you
should note use it on production server without carefully reviewing the
generated iptables rules and assert they match your firewalling
guidelines_.

Now, let's write the iptables role. It's easy to see how to do that:
just write a rules files that will open the right ports. But... what
ports ? How the iptable role can be aware of what roles need which ports
to be openend ?
Of course we could write an iptables role that will be aware of every
possible role (e.g. ssh) and open the right ports for them (e.g.
ssh_port). However, this is a really bad solution. Doing it this way
will introduce a lot of coupling between the iptables
role and all other roles. Maintenance will be a mess, things will break,
our developpers won't access development machines anymore, backend will
refuse to talk to frontends. For short, it will soon be a mess and
everybody will hate us.

So we'll try another approach : let's say that each role is responsible
of generating it's own iptables rules, and the iptable role will take
care of merging them and applying them to the host. This approach sounds
much more reasonable.

This part is a bit technical regarding iptables, but you can just skip
the details and only look at what Ansible can do in this context.

### General iptables structure

To make things simpler, we'll create a skeleton iptables file with 6 new
chains : `TCP_IN`, `TCP_OUT`, `UDP_IN`, `UDP_OUT`, `ICMP_IN`, `ICMP_OUT`.

As the name suggest, each chain will contain rules that relate to
inbound trafic (`TCP_IN`, `UDP_IN`, ...) ou outbound traffic (`ICMP_OUT`,
`TCP_OUT`, etc...).

The default policy for INPUT and OUTPUT chains is DROP, so we just have
to open the firewall for traffic we want to receive (`*_IN`) or emit
(`*_OUT`) for the right protocol (`UDP`, `TCP`, `ICMP`).

Note that we don't care about the `FORWARD` chain : we just don't route
packets. To keep things simple and understandable, we assume that all
hosts have the same requirements regarding ICMP handling and no
customization can be made. This could be changed easily though. Finally,
we just handle the filter table, but the method could extend to any
table with some additional work.

Here is the template we come up with after a pencil/paper session :

    #
    # {{ ansible_managed }}
    #
    # Filter rules
    *filter
    :INPUT DROP [0:0]
    :FORWARD DROP [0:0]
    :OUTPUT DROP [0:0]
    :DROP_IT - [0:0]
    :ICMP_IN - [0:0]
    :ICMP_OUT - [0:0]
    :STATEFUL - [0:0]
    :TCP_IN - [0:0]
    :TCP_OUT - [0:0]
    :UDP_IN - [0:0]
    :UDP_OUT - [0:0]
    #
    # ######################################
    # INPUT Dispatch
    # ######################################
    -A INPUT -i lo -j ACCEPT
    -A INPUT -m state --state INVALID -j DROP_IT
    -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    -A INPUT -s 127.0.0.0/255.0.0.0 ! -i lo -j DROP_IT
    -A INPUT -p tcp -j TCP_IN
    -A INPUT -p udp -j UDP_IN
    -A INPUT -p icmp -j ICMP_IN
    #
    # ######################################
    # OUTPUT Dispatch
    # ######################################
    -A OUTPUT -o lo -j ACCEPT
    -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    -A OUTPUT -p udp -j UDP_OUT
    -A OUTPUT -p tcp -j TCP_OUT
    -A OUTPUT -p icmp -j ICMP_OUT
    #
    # ######################################
    # DROP & log rules
    # ######################################
    {% if firewall_log_drops %}
    -A DROP_IT -p tcp -m limit --limit 10/min -j LOG --log-prefix "Drop:" --log-level 6
    -A DROP_IT -p udp -m limit --limit 10/min -j LOG --log-prefix "Drop:" --log-level 6
    {% endif %}
    -A DROP_IT -j DROP
    #
    # ######################################
    # ICMP IN
    # ######################################
    -A ICMP_IN -p icmp --icmp-type 3 -j ACCEPT
    -A ICMP_IN -p icmp --icmp-type 11 -j ACCEPT
    -A ICMP_IN -p icmp --icmp-type 0 -j ACCEPT
    -A ICMP_IN -p icmp --icmp-type 8 -m limit --limit 5/sec -j ACCEPT
    #
    # ######################################
    # ICMP OUT
    # ######################################
    -A ICMP_OUT -p icmp --icmp-type 8 -j ACCEPT
    #
    # ######################################
    # TCP INPUT RULES
    # ######################################
    -A TCP_IN -p tcp ! --tcp-flags SYN,RST,ACK SYN -m state --state NEW -j DROP_IT
    ### Temporary safeguard !
    -A TCP_IN -p tcp --dport 22 -j ACCEPT
    #
    ### Placeholder for rules
    #
    # ######################################
    # TCP OUTPUT RULES
    # ######################################
    {% if firewall_unfilter_tcp_out == True %}
    -A TCP_OUT -p tcp -j ACCEPT
    {% else %}
    ### Placeholder for rules
    {% endif %}{# unfilter_tcp_out #}
    #
    # ######################################
    # UDP INPUT RULES
    # ######################################
    #
    ### Placeholder for rules
    #
    # ######################################
    # UDP OUTPUT RULES
    # #######################################
    {% if firewall_unfilter_udp_out == True -%}
    -A UDP_OUT -p udp -j ACCEPT
    {% else %}
    ### Placeholder for rules
    {% endif %}
    COMMIT

I won't delve into the details of the rules, but it can be noticed that
we already have some Jinja directives in the template : we can choose
whether we are going to log dropped packets or not by setting
`firewall_log_drops` to yes or no. This variable is a good candidate to be
in our `vars/main.yml`.
We also have the ability to let all out traffic out without filtering
using `firewall_unfilter_tcp_out` for TCP and
`firewall_unfilter_udp_out` for UDP. These vars will also end in our
`vars/main.yml` file, and we'll set them to relaxed defaults for now:

    firewall_unfilter_udp_out: yes
    firewall_unfilter_tcp_out: yes
    firewall_log_drops: yes

We're need a task file to render this template :

    - name: Generate iptable rules
      template: src="../templates/iptables.j2" dest=/etc/network/iptables mode=0640 owner=root group=root
      tags: iptables
      notify: restart iptables

a handler to reload rules :

    - name: Restart iptables
      shell: iptables-restore < /etc/network/iptables

and finally we need to include this role in our main playbook
(step-13/site.yml), like so :

    - hosts: all
      roles:
        - { role: iptables }
        - { role: ssh }

    - hosts: web
      roles:
        - { role: apache }

    - hosts: haproxy
      roles:
        - { role: haproxy }

Note that we introduced a new way to write an action in the iptables and
sshd task and handler files: until now, our tasks looked like `action:
somemodulename args...`. But there is a nice shorthand to write the same
action : `somemodulename: args...`. It's less verbose and easier to
read. We'll use this syntax from now on (other roles have been changed
to this syntax too).

### Deploying

Let's try that on host1.example.org (assuming you come from step-12).
We'll use the `iptables` tag so we don't span the entire playbook and
get to the point quicker.

    ansible-playbook -i step-13/hosts step-13/site.yml -l host1.example.org -t iptables

The output should look like :

# TBD : check loaded lodules difference for connexion tracking that
breaks first iptabmes push

So we already have a working iptables rules files !

However, this is just the baseline config. We'll see in
[step-14](https://github.com/leucos/ansible-tuto/tree/master/step-14)
how we will take advantage of this from other roles.

