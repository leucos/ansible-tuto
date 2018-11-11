# Ansible tutorial: Refining apache setup

We've installed apache, now lets set up our virtualhost.

## Refining the playbook

We need just one virtualhost on our server, but we want to replace the default
one with something more specific. So we'll have to remove the current
(presumably `default`) virtualhost, send our virtualhost, activate it and
restart apache.

Let's create a directory called `files`, and add our virtualhost configuration
for host1, which we'll call `awesome-app`:

```xml
<VirtualHost *:80>
  DocumentRoot /var/www/awesome-app

  Options -Indexes

  ErrorLog /var/log/apache2/error.log
  TransferLog /var/log/apache2/access.log
</VirtualHost>
```

Now, a quick update to our apache playbook and we're set:

```yaml
- hosts: web
  tasks:
    - name: Installs apache web server
      apt:
        pkg: apache2
        state: present
        update_cache: true

    - name: Push default virtual host configuration
      copy:
        src: files/awesome-app
        dest: /etc/apache2/sites-available/awesome-app
        mode: 0640

    - name: Disable the default virtualhost
      file:
        dest: /etc/apache2/sites-enabled/default
        state: absent
      notify:
        - restart apache

    - name: Disable the default ssl virtualhost
      file:
        dest: /etc/apache2/sites-enabled/default-ssl
        state: absent
      notify:
        - restart apache

    - name: Activates our virtualhost
      file:
        src: /etc/apache2/sites-available/awesome-app
        dest: /etc/apache2/sites-enabled/awesome-app
        state: link
      notify:
        - restart apache

  handlers:
    - name: restart apache
      service:
        name: apache2
        state: restarted
```

Here we go:

```bash
$ ansible-playbook -i step-05/hosts -l host1 step-05/apache.yml

PLAY [web] *********************

GATHERING FACTS *********************
ok: [host1]

TASK: [Installs apache web server] *********************
ok: [host1]

TASK: [Push default virtual host configuration] *********************
changed: [host1]

TASK: [Disable the default virtualhost] *********************
changed: [host1]

TASK: [Disable the default ssl virtualhost] *********************
changed: [host1]

TASK: [Activates our virtualhost] *********************
changed: [host1]

NOTIFIED: [restart apache] *********************
changed: [host1]

PLAY RECAP *********************
host1              : ok=7    changed=5    unreachable=0    failed=0
```

Pretty cool! Well, thinking about it, we're getting ahead of ourselves here.
Shouldn't we check that the config is ok before restarting apache? This way we
won't end up interrupting the service if our configuration file is incorrect.

Lets do that in
[step-06](https://github.com/leucos/ansible-tuto/tree/master/step-06).
