# Ansible tutorial: Restarting when config is correct

We've installed apache, pushed our virtualhost and restarted the server. But
what if we wanted the playbook to restart the server only if the config is
correct? Let's do that.

## Bailing out when things go wrong

Ansible has a nifty feature: it will stop all processing if something goes
wrong. We'll take advantage of this feature to stop our playbook if the config
file is not valid.

Let's change our `awesome-app` virtual host configuration file and break it:

```xml
<VirtualHost *:80>
  RocumentDoot /var/www/awesome-app

  Options -Indexes

  ErrorLog /var/log/apache2/error.log
  TransferLog /var/log/apache2/access.log
</VirtualHost>
```

As said, when a task fails, processing stops. So we'll ensure that the
configuration is valid before restarting the server. We also start by adding
our  virtualhost _before_ removing the default virtualhost, so a subsequent
restart (possibly done directly on the server) won't break apache.

Note that we should have done this in the first place. Since we ran our
playbook already, the default virtualhost is already deactivated. Nevermind:
this playbook might be used on other innocent hosts, so let's protect them.

```yaml
- hosts: web
  tasks:
    - name: Installs apache web server
      apt:
        pkg: apache2
        state: present
        update_cache: true

    - name: Push future default virtual host configuration
      copy:
        src: files/awesome-app
        dest: /etc/apache2/sites-available/
        mode: 0640

    - name: Activates our virtualhost
      command: a2ensite awesome-app

    - name: Check that our config is valid
      command: apache2ctl configtest

    - name: Deactivates the default virtualhost
      command: a2dissite default

    - name: Deactivates the default ssl virtualhost
      command: a2dissite default-ssl
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
$ ansible-playbook -i step-06/hosts -l host1 step-06/apache.yml

PLAY [web] *********************

GATHERING FACTS *********************
ok: [host1]

TASK: [Installs apache web server] *********************
ok: [host1]

TASK: [Push future default virtual host configuration] *********************
changed: [host1]

TASK: [Activates our virtualhost] *********************
changed: [host1]

TASK: [Check that our config is valid] *********************
failed: [host1] => {"changed": true, "cmd": ["apache2ctl", "configtest"], "delta": "0:00:00.045046", "end": "2013-03-08 16:09:32.002063", "rc": 1, "start": "2013-03-08 16:09:31.957017"}
stderr: Syntax error on line 2 of /etc/apache2/sites-enabled/awesome-app:
Invalid command 'RocumentDoot', perhaps misspelled or defined by a module not included in the server configuration
stdout: Action 'configtest' failed.
The Apache error log may have more information.

FATAL: all hosts have already failed -- aborting

PLAY RECAP *********************
host1              : ok=4    changed=2    unreachable=0    failed=1
```

As you can see since `apache2ctl` returns with an exit code of 1 when it fails,
ansible is aware of it and stops processing. Great!

Mmmh, not so great in fact... Our virtual host has been added anyway. Any
subsequent apache restart will complain about our config and bail out. So we
need a way to catch failures and revert back.

Let's do that in
[step-07](https://github.com/leucos/ansible-tuto/tree/master/step-07).
