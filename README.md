# Ansible tutorial

This tutorial presents Ansible step-by-step. You'll need to have a (virtual or
physical) machine to act as an Ansible node. A Vagrant environment is provided for 
going through this tutorial.

Ansible is a configuration management software that lets you control and
configure nodes from  another machine. What makes it different from other
management software is that Ansible  uses (potentially existing) SSH
infrastructure, while others (Chef, Puppet, ...) need a specific PKI
infrastructure to be set up.

Ansible also emphasises push mode, where configuration is pushed from a master
machine (a master machine is only a machine where you can SSH to nodes from) to
nodes, while most other CM typically do it the other way around (nodes pull
their config at times from a master machine).

This mode is really interesting since you do not need to have a 'publicly'
accessible 'master' to be able to configure remote nodes: it's the nodes
that need to be accessible (we'll see later that 'hidden' nodes can pull their
configuration too!), and most of the time they are.

This tutorial has been tested with **Ansible 2.7.1**.

We're also assuming you have a keypair in your ~/.ssh directory.

## Quick start

- install Vagrant if you don't have it
- install ansible (preferably 2.7.1 and using pip+virtualenv)
- `vagrant up`
- goto [step-00](./step-00/README.md)

## Complete explanations

### Installing Ansible

The reference is the [installation
guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html),
but I strongly recomment the [Using pip & virtualenv (higly recommended
!)](#using-pip--virtualenv-higly-recommended-) method.

#### Using pip & virtualenv (higly recommended !)

The best way to install Ansible (by far) is to use `pip` andf virtual
environments.

Using virtualenv will let you have multiple Ansible versions
installed side by side, and test upgrades or use different versions in
different projects. Also, by using a virtualenv, you won't pollute your
system's python installation.

Check
[virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/)
for this. It makes managing virtualenvs very easy.

Under Ubuntu, installing virtualenv & virtualenvwrapper can be done like
so:

```bash
sudo apt-get install python-virtualenv virtualenvwrapper python-pip
exec $SHELL
```

You can then create a virtualenv:

```bash
mkvirtualenv ansible-tuto
workon ansible-tuto
```

(`mkvirtualenv` usually switches you automatically to your newly created
virtualenv, so here `workon ansible-tuto` is not strictly necessary, but
lets be safe).

Then, install ansible via `pip`:

```bash
pip install ansible==2.7.1
```

(or use whatever version you want).

When you're done, you can deactivate your virtualenv to return to your
system's python settings & modules:

```bash
deactivate
```

If you later want to return to your virtualenv:

```bash
workon ansible-tuto
```

Use `lsvirtualenv` to list all your virtual environments.

#### From source (if you want to hack on ansible source code)

Ansible devel branch is always usable, so we'll run straight from a git checkout.
You might need to install git for this (`sudo apt-get install git` on Debian/Ubuntu).

```bash
git clone git://github.com/ansible/ansible.git
cd ./ansible
```

At this point, we can load the Ansible environment:

```bash
source ./hacking/env-setup
```

#### From a distribution package (discouraged)

```bash
sudo apt-get install ansible
```

#### From a built deb package (discouraged)

When running from an distribution package, this is absolutely not
necessary. If you prefer running from an up to date Debian package,
Ansible provides a `make target` to build it. You need a few packages to
build the deb and
few dependencies:

```bash
sudo apt-get install make fakeroot cdbs python-support python-yaml python-jinja2 python-paramiko python-crypto python-pip
git clone git://github.com/ansible/ansible.git
cd ./ansible
make deb
sudo dpkg -i ../ansible_x.y_all.deb (version may vary)
```

### Cloning the tutorial

```bash
git clone https://github.com/leucos/ansible-tuto.git
cd ansible-tuto
```

### Running the tutorials interactively with Docker

You can run the tutorials here interactively including a very simple setup with docker.

Check [this repository](https://github.com/turkenh/ansible-interactive-tutorial) for details.

### Using Vagrant with the tutorial

It's highly recommended to use Vagrant to follow this tutorial. If you don't have 
it already, setting up should be quite easy and is described in [step-00/README.md](https://github.com/leucos/ansible-tuto/tree/master/step-00/README.md).

If you wish to proceed without Vagrant (not recommended!), go straight to
[step-01/README.md](https://github.com/leucos/ansible-tuto/tree/master/step-01).

## Contents

[Terminology](https://docs.ansible.com/ansible/glossary.html):
 - [command or
   action](https://docs.ansible.com/ansible/intro_adhoc.html): [ansible module](https://docs.ansible.com/ansible/modules.html) executed in
   stand-alone mode. Intro in [step-02](https://github.com/leucos/ansible-tuto/tree/master/step-02).
 - task: combines an action (a module and its arguments) with a name
   and optionally some other keywords (like looping directives).
 - play: a yaml structure executing a list of roles or tasks over a list
   of hosts
 - [playbook](https://docs.ansible.com/ansible/playbooks_intro.html):
   yaml file containing multiple plays. Intro in
   [step-04](https://github.com/leucos/ansible-tuto/tree/master/step-04).
 - [role](https://docs.ansible.com/ansible/playbooks_roles.html): an
   organisational unit grouping tasks together in order to achieve
   something (install a piece of software for instance). Intro in
   [step-12](https://github.com/leucos/ansible-tuto/tree/master/step-12).

Just in case you want to skip to a specific step, here is a topic table of contents.

- [00. Vagrant Setup](https://github.com/leucos/ansible-tuto/tree/master/step-00)
- [01. Basic inventory](https://github.com/leucos/ansible-tuto/tree/master/step-01)
- [02. First modules and facts](https://github.com/leucos/ansible-tuto/tree/master/step-02)
- [03. Groups and variables](https://github.com/leucos/ansible-tuto/tree/master/step-03)
- [04. Playbooks](https://github.com/leucos/ansible-tuto/tree/master/step-04)
- [05. Playbooks, pushing files on nodes](https://github.com/leucos/ansible-tuto/tree/master/step-05)
- [06. Playbooks and failures](https://github.com/leucos/ansible-tuto/tree/master/step-06)
- [07. Playbook conditionals](https://github.com/leucos/ansible-tuto/tree/master/step-07)
- [08. Git module](https://github.com/leucos/ansible-tuto/tree/master/step-08)
- [09. Extending to several hosts](https://github.com/leucos/ansible-tuto/tree/master/step-09)
- [10. Templates](https://github.com/leucos/ansible-tuto/tree/master/step-10)
- [11. Variables again](https://github.com/leucos/ansible-tuto/tree/master/step-11)
- [12. Migrating to roles](https://github.com/leucos/ansible-tuto/tree/master/step-12)
- [13. Using tags (TBD)](https://github.com/leucos/ansible-tuto/tree/master/step-13)
- [14. Roles dependencies (TBD)](https://github.com/leucos/ansible-tuto/tree/master/step-14)
- [15. Debugging (TBD)](https://github.com/leucos/ansible-tuto/tree/master/step-15)
- [99. The end](https://github.com/leucos/ansible-tuto/tree/master/step-99)

## Contributing

Thanks to all people who have contributed to this tutorial:

* [Aladin Jaermann](http://github.com/oxyrox)
* [Alexis Gallagher](https://github.com/algal)
* [Alice Ferrazzi](https://github.com/aliceinwire)
* [Alice Pote](https://github.com/aliceriot)
* [Amit Jakubowicz](https://github.com/amitit)
* [Anonymous Contributor](https://github.com/terroirman)
* [Arbab Nazar](https://github.com/arbabnazar)
* [Atilla Mas](https://github.com/atillamas)
* [Ben Visser](https://github.com/noqcks)
* [Benny Wong](https://github.com/bdotdub)
* [Bernardo Vale](https://github.com/bernardoVale)
* [Chris Schmitz](https://github.com/ccschmitz)
* [dalton](https://github.com/dalton)
* [Daniel Howard](https://github.com/dannyman)
* [David Golden](https://github.com/dagolden)
* [Davide Restivo](https://github.com/daviderestivo)
* [Eric Corson](https://github.com/frodopwns)
* [Eugene Kalinin](https://github.com/ekalinin)
* [Ludovic Gasc](https://github.com/GMLudo)
* [Hartmut Goebel](https://github.com/htgoebel)
* [Jelly Robot](https://github.com/jellyjellyrobot)
* [Justin Garrison](https://github.com/rothgar)
* [Karlo](https://github.com/karlo57)
* [Marchenko Alexandr](https://github.com/mac2000)
* [mxxcon](https://github.com/mxxcon)
* [Patrick Pelletier](https://github.com/skinp)
* [Pierre-Gilles Levallois](https://github.com/Pilooz)
* [Ruud Kamphuis](https://github.com/ruudk)
* [tkermode](https://github.com/tkermode)
* [torenware](https://github.com/torenware)
* [Victor Boivie](https://github.com/boivie)
* [Yauheni Dakuka](https://github.com/ydakuka)

(and sorry if I forgot anyone)

I've been using Ansible almost since its birth, but I learned a lot in
the process of writing it. If you want to jump in, it's a great way to
learn, feel free to add your contributions.

The chapters being written live in the
[writing](https://github.com/leucos/ansible-tuto/tree/writing) branch.

If you have ideas on topics that would require a chapter, please open a
PR.

I'm also open on pairing for writing chapters. Drop me a note if you're
interested.

If you make changes or add chapters, please fill the `test/expectations`
file and run the tests (`test/run.sh`).
See the `test/run.sh` file for (a bit) more information.

When adding a new chapter (e.g. `step-NN`), please issue:

```bash
cd step-99
ln -sf ../step-NN/{hosts,roles,site.yml,group_vars,host_vars} .
```

For typos, grammar, etc... please send a PR for the master branch
directly.

Thank you!
