# The end

At this point, you can try building up everything from scratch, to see
if you can properly provision your cluster with your playbook.

Fire in the hole!

    vagrant destroy -f
    vagrant up
    ansible-playbook -c paramiko -i step-00/hosts step-00/setup.yml --ask-pass --sudo

(you might need to wait a little for the network to come up before
running the last command).

All the preceeding commands are just here to set-up our test
environment. Deploying on the blank machines just requires one line:

    ansible-playbook -i step-99/hosts step-99/site.yml

Just one command to rule them all: you have your cluster, can add nodes ad
nauseam, tune settings, ... all this can be extended at will with more variables, 
other plays, etc...

# The end

Ok, seems we're done with our tutorial. Hope you enjoyed playing with Ansible, and 
felt the power of this new tool.

Now go straight to [Ansible website](http://ansible.cc), dive in the docs, check references, 
skim through playbooks, chat on freenode in #ansible, and foremost, have fun!
