name             'pio'
maintainer       'ActionML'
maintainer_email 'devops@actionml.com'
license          'Apache 2.0'
description      'Installs/Configures PIO'
long_description 'Installs/Configures PredictionIO an open source Machine Learning Server '\
                 'built on top of state-of-the-art open source stack for developers and '\
                 'data scientists create predictive engines for any machine learning task.'
version          '0.1.2'

chef_version ">= 12"

# Supported platforms
supports 'ubuntu', '>= 14.04'
supports 'centos', '>= 7'


# Cookbook dependencies
depends 'apt'
depends 'build-essential'
depends 'java'
depends 'git'
depends 'ark'
depends 'sudo'
depends 'poise-python'
depends 'ulimit'
depends 'elasticsearch', '= 2.5.0'
depends 'service_manager'
