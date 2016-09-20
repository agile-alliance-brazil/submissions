# Conference Submission System
[![Build Status](https://snap-ci.com/agile-alliance-brazil/submissions/branch/master/build_image)](https://snap-ci.com/agile-alliance-brazil/submissions/branch/master) [![Dependency Status](https://gemnasium.com/agile-alliance-brazil/submissions.svg)](https://gemnasium.com/agile-alliance-brazil/submissions) [![Code Climate](https://codeclimate.com/github/agile-alliance-brazil/submissions/badges/gpa.svg)](https://codeclimate.com/github/agile-alliance-brazil/submissions) [![Test Coverage](https://codeclimate.com/github/agile-alliance-brazil/submissions/badges/coverage.svg)](https://codeclimate.com/github/agile-alliance-brazil/submissions)
===================

This is an open-source conference submission system, built in Rails and has been used for the [Agile Brazil](http://www.agilebrazil.com) conference since 2010. Some of the features supported are:

* User registration
* User profiles
* Support for I18N (currently supports: en, pt-br)
* Conference tracks, audience levels, and different session types
* Session submission
* Comments on sessions
* Phases and deadlines (submission, early review, review, program compilation)
* E-mail notifications
* Track organizers
* Reviewers
* Adding reviews and feedback to authors
* Review decisions of acceptance/rejection and e-mail publishing
* More...

# Development

Just clone this repo (including submodules so ensure you run `git clone https://github.com/agilealliancebrazil/submissions.git  --recursive` or if you already cloned, use `git submodule foreach git pull origin master`), enter it and run `./dev.sh`. This should be enough to install whatever is needed on your machine and start guard to run specs and front end tests.

If you don't want to mess with your own machine, an option to use [Vagrant](https://www.vagrantup.com/) for development is available. Download [Vagrant 1.8.1](https://releases.hashicorp.com/vagrant/1.8.1/) and [Virtual Box](https://www.virtualbox.org/wiki/Downloads), install both and then run:

```sh
vagrant destroy -f dev && vagrant up dev && vagrant ssh dev
````

Once inside the vagrant box, run `/srv/apps/registrations/current/dev.sh`. Note that the code will be sync'ed between the virtual machine and your machine so you can still use your favorite editor and handle version control from your machine if you prefer.

## Deployment

Provisioning is handled by [Puppet](https://puppetlabs.com/) [4.3.1](http://docs.puppetlabs.com/puppet/latest/reference/install_pre.html). It can be tested with [Vagrant](https://www.vagrantup.com/) [1.8.1](https://releases.hashicorp.com/vagrant/1.8.1/).

Deployment is handled by [Capistrano](http://capistranorb.com/). And can also be tested using the vagrant set up.

To test, run:
```sh
vagrant destroy -f deploy && vagrant up deploy && bundle && bundle exec ruby deploy/first_deploy.rb vagrant 10.11.12.16 staging certs/insecure_private_key
```

Note that Capistrano uses the code currently available in github so you need to push to test it.
You can set up `config/deploy/vagrant.rb` to use a different branch with `set :branch, 'your_branch'`.

### Deploying to a cloud

If you're deploying to any cloud, after you've created your virtual machine, add `config/<vms_ip>_config.yml`, `config/<vms_ip>_database.yml`, `config/<vms_ip>_newrelic.yml`. You can, optionally, also add `certs/<vms_ip>_server.crt`, `certs/<vms_ip>_server_key.pem` and `certs/<vms_ip>_server_key.pem` to set up apache to work with SSL. Then run:
```sh
bundle && bundle exec ruby deploy/first_deploy.rb <configured_sudoer_user> <vms_ip> <type> <ssh_key_to_access_vm>
```
Where your sudoer user is a user in that machine that has sudo right (no password required), vms_ip is the vm IPv4 addres, type is either 'production' or 'staging' and the ssh key is the path in your machine to the ssh key that allows non password protected access to your cloud VM.

#### Digital Ocean

If you're deploying to [Digital Ocean](https://www.digitalocean.com/?refcode=f3805af8abc0) specifically, go to your [API settings](https://cloud.digitalocean.com/settings/applications), request a Personal Access Token, save it and run:
```sh
export TOKEN=<your_token>
```

From then on, you can use:
```sh
bundle && bundle exec ruby deploy/digital_ocean/new_machine.rb
```

# Feedback

If you have a bug or a feature request, please create a issue here:

[https://github.com/agile-alliance-brazil/submissions/issues](https://github.com/agile-alliance-brazil/submissions/issues)

# Team

Thanks to all our [contributors](https://github.com/agile-alliance-brazil/submissions/contributors)! The core team is:

* [Hugo Corbucci](http://hugocorbucci.com) (Core Developer)

Our huge thanks to past developers:

* [Danilo Sato](http://www.dtsato.com) (Original Developer)

# License

The conference submission system is released under the [MIT license](http://www.opensource.org/licenses/MIT). See LICENSE for details.