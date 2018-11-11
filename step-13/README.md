# Ansible tutorial: Using tags

We are starting to have real fun now. With a press of a button, we can
deploy our loadbalancer and web app. This is awesome !

However, as our playbooks grow, having to go through all the tasks every
time is a waste of time. Enter tags.

## Leveraging tags

Tags will let you select which part of the playbook you want to run. For
instance, if you change your HAproxy configuration, you don't really
need to run the Apache playbook. By using tags, you can tell Ansible
"Hey, just run the tasks taggued with HAproxy". You can even negate
tags, asking "Hey Ansible, run all tasks but HAproxy ones".

You can also ask things like "run tasks tagged A or B, but not C".

## Basic syntax

Tagging a task is as simple as adding the keyword `tags:` and a list of
tags. Example:

```yaml
- name: Do something really interesting
  debug: msg="Yes this does something really interesting"
  tags:
    - interesting
    - awesome
```

An alternate Yaml syntax is :

```yaml
- name: Do something really interesting
  debug: msg="Yes this does something really interesting"
  tags: ['interesting', 'awesome']
```

Now you can ask Ansible to execute tasks having tags by using `-t` at
the command line:

```bash
ansible-playbook pbook.yml -t interesting
```

The previous task will be executed when:

- no tags are provided at the command line
- `-t interesting` is provided
- `-t awesome` is provided
- or when multiple tags are provided `-t boring,interesting` -or by repeating
  `-t` like in `-t boring -t interesting`)

## Hands on

Not really hard. Lets apply this to our apache roles.

```yaml
- name: Installs necessary packages
  apt:
    pkg: ["apache2", "libapache2-mod-php", "git"]
    state: latest
    update_cache: true
  tags:
    - apache

- name: Push future default virtual host configuration
  copy:
    src: awesome-app
    dest: /etc/apache2/sites-available/awesome-app.conf
    mode: 0640
  tags:
    - apache

- name: Activates our virtualhost
  command: a2ensite awesome-app
  tags:
    - apache

- name: Check that our config is valid
  command: apache2ctl configtest
  register: result
  ignore_errors: true
  tags:
    - apache

- name: Rolling back - Restoring old default virtualhost
  command: a2ensite 000-default
  when: result is failed
  tags:
    - apache

- name: Rolling back - Removing out virtualhost
  command: a2dissite awesome-app
  when: result is failed
  tags:
    - apache

- name: Rolling back - Ending playbook
  fail:
    msg: "Configuration file is not valid. Please check that before re-running the playbook."
  when: result is failed
  tags:
    - apache

- name: Deploy our awesome application
  git:
    repo: https://github.com/leucos/ansible-tuto-demosite.git
    dest: /var/www/awesome-app
  tags:
    - deploy
    - apache

- name: Deactivates the default virtualhost
  command: a2dissite 000-default
  tags:
    - apache

- name: Deactivates the default ssl virtualhost
  command: a2dissite default-ssl
  tags:
    - apache
  notify:
    - restart apache
```

Well not hard, but insanely boring !
You probably noticed that I already slipped in a tag in the previous
chapters (`deploy`). Now we added the `apache` tag too.

But for now, we'll see how we can deploy firewall rules for our cluster
in [step-13](https://github.com/leucos/ansible-tuto/tree/master/step-13)
chapter about "Deploying firewall rules". In this chapter, we'll use
role dependencies to build our systems.
