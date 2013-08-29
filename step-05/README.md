Ansible tutorial
================

Refining apache setup
---------------------

We've instaled apache, now lets set up our virtualhost.

# Refining the playbook

We need just one virtualhost on our server, but we want to replace the
default one with something more specific.
So we'll have to remove the current (presumably `default`) virtualhost, send our 
virtualhost, activate it and restart apache.

Let's create a directory called `files`, and add our virtualhost configuration
for host1.example.org, which we'll call `awesome-app` :

    <VirtualHost *:80>
      DocumentRoot /var/www/awesome-app

      Options -Indexes

      ErrorLog /var/log/apache2/error.log
      TransferLog /var/log/apache2/access.log
    </VirtualHost>

Now, a quick update to our apache playbook and we're set :

    - hosts: web
      sudo: True
      tasks:
        - name: Installs apache web server
          action: apt pkg=apache2 state=installed update_cache=true

        - name: Push default virtual host configuration
          action: copy src=files/awesome-app dest=/etc/apache2/sites-available/ mode=0640 

        - name: Deactivates the default virtualhost
          action: command a2dissite default

        - name: Deactivates the default ssl virtualhost
          action: command a2dissite default-ssl

        - name: Activates our virtualhost
          action: command a2ensite awesome-app
          notify:
            - restart apache

      handlers:
        - name: restart apache
          action: service name=apache2 state=restarted

Here we go :

    $ ansible-playbook -i step-05/hosts -l host1.example.org step-05/apache.yml

    PLAY [web] ********************* 

    GATHERING FACTS ********************* 
    ok: [host1.example.org]

    TASK: [Installs apache web server] ********************* 
    ok: [host1.example.org]

    TASK: [Push default virtual host configuration] ********************* 
    changed: [host1.example.org]

    TASK: [Deactivates the default virtualhost] ********************* 
    changed: [host1.example.org]

    TASK: [Deactivates the default ssl virtualhost] ********************* 
    changed: [host1.example.org]

    TASK: [Activates our virtualhost] ********************* 
    changed: [host1.example.org]

    NOTIFIED: [restart apache] ********************* 
    changed: [host1.example.org]

    PLAY RECAP ********************* 
    host1.example.org              : ok=7    changed=5    unreachable=0    failed=0    

Pretty cool! Well, thinking about it, we're getting ahead of ourselves here. Shouldn't 
we check that the config is ok before restarting apache? This way we won't end up 
interrupting the service if our configuration file is incorrect.

Lets do that in the next step (`./step-06`, or click
[here](https://github.com/leucos/ansible-tuto/tree/master/step-06)).
