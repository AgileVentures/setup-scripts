setup-scripts
=============

Contains shared setup scripts for AgileVentures projects

### rails_setup.sh

~~~
source ./scripts/rails_setup.sh
~~~

This script sets up the environment with a basic Rails setup, which is commonly
used throughout AgileVentures projects. This includes the following tools:

* [curl](http://curl.haxx.se/)
* [bundler](http://bundler.io/)
* [RVM](https://rvm.io/)
* [nodejs](http://nodejs.org/) and [npm](https://www.npmjs.org/)
* Options:
 - `$REQUIRED_RUBY` - specifies the required ruby version
 - `$GEMSET` - names the gemset to be used
 - `$SKIP_BUNDLE` - if set, will skip bundle install
 - `$SKIP_MIGRATIONS` - if set, will skip migrations
 - `$WITH_PHANTOMJS` - if set, will install [phantomjs](http://phantomjs.org/)

This script assumes you have PostgreSQL all set up, if you don't know how to set
it up, please refer to [this](https://github.com/AgileVentures/LocalSupport/wiki/installation#postgresql-install) guide
