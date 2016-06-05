Ansible tutorial
================

Deploying our website from git
------------------------------

We've installed apache, pushed our virtualhost and restarted the server safely.
Now we'll use the git module to deploy our application.

# The git module

Well, this is a kind of break. Nothing necessarily new here. The `git` module is 
just another module. But we'll try it out just for fun. And we'll be familiar with 
it when it comes to `ansible-pull` later on.

Our virtualhost is set, but we need a few changes to finish our deployment.
First, we're deploying a PHP application. So we need to install the
`libapache2-mod-php5` package. Second, we have to install `git` since the
git module (used to clone our application's git repository) uses it.

We could do it like this:

```
...
- name: Installs apache web server
  apt: pkg=apache2 state=installed update_cache=true

- name: Installs php5 module
  apt: pkg=libapache2-mod-php5 state=installed

- name: Installs git
  apt: pkg=git state=installed
...
```

but Ansible provides a more readable way to write this. Ansible can loop over a series 
of items, and use each item in an action like this:


```yaml
- hosts: web
  tasks:
    - name: Updates apt cache
      apt: update_cache=true

    - name: Installs necessary packages
      apt: pkg={{ item }} state=latest 
      with_items:
        - apache2
        - libapache2-mod-php5
        - git

    - name: Push future default virtual host configuration
      copy: src=files/awesome-app dest=/etc/apache2/sites-available/ mode=0640

    - name: Activates our virtualhost
      command: a2ensite awesome-app

    - name: Check that our config is valid
      command: apache2ctl configtest
      register: result
      ignore_errors: True

    - name: Rolling back - Restoring old default virtualhost
      command: a2ensite default
      when: result|failed

    - name: Rolling back - Removing out virtualhost
      command: a2dissite awesome-app
      when: result|failed

    - name: Rolling back - Ending playbook
      fail: msg="Configuration file is not valid. Please check that before re-running the playbook."
      when: result|failed

    - name: Deploy our awesome application
      git: repo=https://github.com/leucos/ansible-tuto-demosite.git dest=/var/www/awesome-app
      tags: deploy

    - name: Deactivates the default virtualhost
      command: a2dissite default

    - name: Deactivates the default ssl virtualhost
      command: a2dissite default-ssl
      notify:
        - restart apache

  handlers:
    - name: restart apache
      service: name=apache2 state=restarted
```


Here we go:

```bash
$ ansible-playbook -i step-08/hosts -l host1.example.org step-08/apache.yml

PLAY [web] ********************* 

GATHERING FACTS ********************* 
ok: [host1.example.org]

TASK: [Updates apt cache] ********************* 
ok: [host1.example.org]

TASK: [Installs necessary packages] ********************* 
changed: [host1.example.org] => (item=apache2,libapache2-mod-php5,git)

TASK: [Push future default virtual host configuration] ********************* 
changed: [host1.example.org]

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

TASK: [Deactivates the default ssl virtualhost] ********************* 
changed: [host1.example.org]

NOTIFIED: [restart apache] ********************* 
changed: [host1.example.org]

PLAY RECAP ********************* 
host1.example.org              : ok=10   changed=8    unreachable=0    failed=0    
```

You can now browse to http://192.168.33.11, and it should display a
kitten, and the server hostname.

Note the `tags: deploy` line allows you to execute just a part of the playbook. 
Let's say you push a new version for your site. You want to speed up and execute 
only the part that takes care of deployment. Tags allows you to do it.
Of course, "deploy" is just a string, it doesn't have any specific
meaning and can be anything. Let's see how to use it:

```bash
$ ansible-playbook -i step-08/hosts -l host1.example.org step-08/apache.yml -t deploy 
X11 forwarding request failed on channel 0

PLAY [web] ********************* 

GATHERING FACTS ********************* 
ok: [host1.example.org]

TASK: [Deploy our awesome application] ********************* 
changed: [host1.example.org]

PLAY RECAP ********************* 
host1.example.org              : ok=2    changed=1    unreachable=0    failed=0    
```
 
Ok, let's deploy another web server in [step-09](https://github.com/leucos/ansible-tuto/tree/master/step-09).
