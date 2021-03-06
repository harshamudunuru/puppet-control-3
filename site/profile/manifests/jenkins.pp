class profile::jenkins {
  class { '::jenkins':
    version            => 'latest',
    lts                => false,
    service_enable     => false,
    configure_firewall => true,
    executors          => $::processors['count'],
  }

  $plugins = [
    'promoted-builds',
    'git-client',
    'scm-api',
    'mailer',
    'token-macro',
    'matrix-project',
    'ssh-credentials',
    'parameterized-trigger',
    'maven-plugin',
    'rebuild',
    'script-security',
    'junit',
    'github',
    'swarm',
    'git',
    'workflow-aggregator',
    'puppet-enterprise-pipeline',
    'structs',
    'javadoc',
    'workflow-scm-step',
    'workflow-cps',
    'workflow-support',
    'workflow-basic-steps',
    'pipeline-input-step',
    'pipeline-milestone-step',
    'pipeline-build-step',
    'pipeline-stage-view',
    'workflow-multibranch',
    'workflow-durable-task-step',
    'workflow-api',
    'pipeline-stage-step',
    'workflow-cps-global-lib',
    'workflow-step-api',
    'workflow-job',
    'plain-credentials',
    'display-url-api',
    'github-api',
    'conditional-buildstep',
    'momentjs',
    'pipeline-rest-api',
    'handlebars',
    'durable-task',
    'ace-editor',
    'jquery-detached',
    'branch-api',
    'cloudbees-folder',
    'pipeline-graph-analysis',
    'run-condition',
    'git-server',
    'rvm',
    'ruby-runtime',
    'pipeline-model-definition',
    'credentials-binding',
    'docker-workflow',
    'pipeline-model-api',
    'pipeline-model-declarative-agent',
    'pipeline-model-extensions',
    'pipeline-stage-tags-metadata',
    'docker-commons',
    'icon-shim',
    'authentication-tokens',
  ]

  jenkins::plugin { $plugins : }

  #jenkins_authorization_strategy { 'hudson.security.AuthorizationStrategy$Unsecured':
  #  ensure => 'present',
  #}

  #jenkins_authorization_strategy { 'hudson.security.FullControlOnceLoggedInAuthorizationStrategy':
#    ensure => 'present',
#  }

  jenkins::user { 'admin':
    email    => 'admin@example.com',
    password => 'admin',
  }

  jenkins::job { 'solitaire_systemjs':
    config  => epp('profile/solitaire_systemjs.xml'),
    require => Package['jenkins'],
  }

  include profile::base

  include profile::nginx

  # Include a reverse proxy in front
  nginx::resource::server { $::hostname:
    listen_port    => 80,
    listen_options => 'default_server',
    proxy          => 'http://localhost:8080',
  }

  # Set Jenkins' default shell to bash
  file { 'jenkins_default_shell':
    ensure  => present,
    path    => '/var/lib/jenkins/hudson.tasks.Shell.xml',
    source  => 'puppet:///modules/profile/hudson.tasks.Shell.xml',
    notify  => Service['jenkins'],
    require => Package['jenkins'],
  }
}
