# Ansible tutorial: Using conditionals

We've installed apache, pushed our virtualhost and restarted the server.
But we want to revert things to a stable state if something goes wrong.

## Reverting when things go wrong

A word of warning: there's no magic here. The previous error was not ansible's
fault. It's not a backup system, and it can't rollback all things. It's your
job to make sure your playbooks are safe. Ansible just doesn't know how to
revert the effects of `a2ensite awesome-app`.

But if we care to do it, it's well within our reach.

As said, when a task fails, processing stops... unless we accept failure (and
we [should](http://www.aaronsw.com/weblog/geremiah)). This is what we'll do:
continue processing if there is a failure but only to revert what we've done.

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
      register: result
      ignore_errors: True

    - name: Rolling back - Restoring old default virtualhost
      command: a2ensite default
      when: result is failed

    - name: Rolling back - Removing our virtualhost
      command: a2dissite awesome-app
      when: result is failed

    - name: Rolling back - Ending playbook
      fail:
        msg: "Configuration file is not valid. Please check that before re-running the playbook."
      when: result is failed

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

The `register` keyword records output from the `apache2ctl configtest`
command (exit status, stdout, stderr, ...), and `when: result|failed`
checks if the registered variable (`result`) contains a failed status.

Here we go:

```bash
$ ansible-playbook -i step-07/hosts -l host1 step-07/apache.yml

PLAY [web] *********************

GATHERING FACTS *********************
ok: [host1]

TASK: [Installs apache web server] *********************
ok: [host1]

TASK: [Push future default virtual host configuration] *********************
ok: [host1]

TASK: [Activates our virtualhost] *********************
changed: [host1]

TASK: [Check that our config is valid] *********************
failed: [host1] => {"changed": true, "cmd": ["apache2ctl", "configtest"], "delta": "0:00:00.051874", "end": "2013-03-10 10:50:17.714105", "rc": 1, "start": "2013-03-10 10:50:17.662231"}
stderr: Syntax error on line 2 of /etc/apache2/sites-enabled/awesome-app:
Invalid command 'RocumentDoot', perhaps misspelled or defined by a module not included in the server configuration
stdout: Action 'configtest' failed.
The Apache error log may have more information.
...ignoring

TASK: [Rolling back - Restoring old default virtualhost] *********************
changed: [host1]

TASK: [Rolling back - Removing our virtualhost] *********************
changed: [host1]

TASK: [Rolling back - Ending playbook] *********************
failed: [host1] => {"failed": true}
msg: Configuration file is not valid. Please check that before re-running the playbook.

FATAL: all hosts have already failed -- aborting

PLAY RECAP *********************
host1              : ok=7    changed=4    unreachable=0    failed=1
```

Seemed to work as expected. Let's try to restart apache to see if it really worked:

```bash
ansible -i step-07/hosts -m service -a 'name=apache2 state=restarted' host1
```

```json
host1 | success >> {
    "changed": true,
    "name": "apache2",
    "state": "started"
}
```

Ok, now our apache is safe from misconfiguration here.

While this sounds like a lot of work, it isn't. Remember you can use variables
almost  everywhere, so it's easy to make this a general playbook for apache,
and use it everywhere to deploy your virtualhosts. Write it once, use it
everywhere. We'll do that in step 9 but for now, let's deploy our web site
using git in
[step-08](https://github.com/leucos/ansible-tuto/tree/master/step-08).
