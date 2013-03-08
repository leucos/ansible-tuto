Ansible tutorial
================

Deploying our webstire from git
-------------------------------

We've instaled apache, pushed our virtualhost and restarted the server safely.
Now we'll use the git module to deploy our application.

# The git module

Well, this is a kind of break. Nothing necessarily new here. The `git` module is 
just another module. But we'll try it out just for fun. And we'll be familiar with 
it when it comes to `ansible-pull` later on.

Our virtualhost is set, but we need a few changes to finish our deployment. First, 
we're deploying a PHP application. So we need to install the `libapache2-mod-php5` package.

We also need to clone our application's git repository.

    - hosts: web
      tasks:
        - name: Installs apache web server
          action: apt pkg=apache2 state=installed

        - name: Installs php5 module
          action: apt pkg=libapache2-mod-php5 state=installed

        - name: Push future default virtual host configuration
          action: copy src=files/awesome-app dest=/etc/apache2/sites-available/ mode=0640

        - name: Activates our virtualhost
          action: command a2ensite awesome-app

        - name: Check that our config is valid
          action: command apache2ctl configtest
          register: result
          ignore_errors: True

        - name: Rolling back - Restoring old default virtualhost
          action: command a2ensite default
          when_failed: $result

        - name: Rolling back - Removing out virtualhost
          action: command a2dissite awesome-app
          when_failed: $result

        - name: Rolling back - Ending playbook
          action: fail msg="Configuration file is not valid. Please check that before re-running the playbook."
          when_failed: $result

        - name: Deploy our awesome application
          action: git repo=https://github.com/leucos/ansible-tuto-demosite.git dest=/var/www/awesome-app
          tags: deploy

        - name: Deactivates the default virtualhost
          action: command a2dissite default

        - name: Deactivates the default virtualhost
          action: command a2dissite default

        - name: Deactivates the default ssl virtualhost
          action: command a2dissite default-ssl
          notify:
            - restart apache

      handlers:
        - name: restart apache
          action: service name=apache2 state=restarted

Here we go :

    $ ansible-playbook -i hosts -l host1.example.org step-08/apache.yml

    PLAY [web] ********************* 

    GATHERING FACTS ********************* 
    ok: [host1.example.org]

    TASK: [Installs apache web server] ********************* 
    ok: [host1.example.org]

    TASK: [Installs php5 module] ********************* 
    changed: [host1.example.org]

    TASK: [Push future default virtual host configuration] ********************* 
    ok: [host1.example.org]

    TASK: [Activates our virtualhost] ********************* 
    changed: [host1.example.org]

    TASK: [Check that our config is valid] ********************* 
    changed: [host1.example.org]

    TASK: [Rolling back - Restoring old default virtualhost] ********************* 
    skipping: [host1.example.org]

    TASK: [Rolling back - Removing out virtualhost] ********************* 
    skipping: [host1.example.org]

    TASK: [Rolling back - Ending playbook] ********************* 
    skipping: [host1.example.org]

    TASK: [Deploy our awesome application] ********************* 
    changed: [host1.example.org]

    TASK: [Deactivates the default virtualhost] ********************* 
    changed: [host1.example.org]

    TASK: [Deactivates the default virtualhost] ********************* 
    changed: [host1.example.org]

    TASK: [Deactivates the default ssl virtualhost] ********************* 
    changed: [host1.example.org]

    NOTIFIED: [restart apache] ********************* 
    changed: [host1.example.org]

    PLAY RECAP ********************* 
    host1.example.org              : ok=11   changed=8    unreachable=0    failed=0    

You can now browse to your server, and it should display a kitten, and the server 
hostname.

Note the `tags: deploy` line ? It allow you to execute just a part of the playbook. 
Let's say you push a new version for your site. You want to speed up and execute 
only the part that takes care of deployment. tags allows you to do it :

    $ ansible-playbook -i hosts -l host1.example.org step-08/apache.yml -t deploy 
    X11 forwarding request failed on channel 0

    PLAY [web] ********************* 

    GATHERING FACTS ********************* 
    ok: [host1.example.org]

    TASK: [Deploy our awesome application] ********************* 
    changed: [host1.example.org]

    PLAY RECAP ********************* 
    host1.example.org              : ok=2    changed=1    unreachable=0    failed=0    

See ?

Ok, let's deploy another web server in the next step (`./step-09`, or click
[here](https://github.com/leucos/ansible-tuto/tree/master/step-09)).
