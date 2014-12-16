class puppetmaster (
  $ip = $::ipaddress_eth1
){
  host{
    'puppet':
      ensure       => 'present',
      ip           => $ip
  }
  package{
    ['puppet','puppet-server']:
      ensure => '3.5.1-1.el6',
      require => Host[$fqdn]
  }
  Service['puppetmaster'] -> Service['puppetdb']

  service { 'puppetmaster':
    ensure => running,
    before => Class['puppetdb'],
    require => Package['puppet-server'],
  }

  exec{
    '/usr/sbin/puppetdb ssl-setup':
      refreshonly => true,
      subscribe => Package['puppetdb'],
      notify => Service['puppetdb'],
      require => Package['puppet-server'],
  }
  class { 'puppetdb':
    listen_address => '0.0.0.0',
    open_ssl_listen_port => true,
    ssl_listen_address => '0.0.0.0',
    puppetdb_version => latest,
    open_listen_port => true,
    require => Package['puppet-server'],
  }
  class {
    'puppetdb::master::config':
      strict_validation => false,
  }

  ini_setting { 'puppet.conf/master/autosign':
    ensure => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'master',
    setting => 'autosign',
    value   => 'true',
  }
  ini_setting { 'puppet.conf/master/certname':
    ensure => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'master',
    setting => 'certname',
    value   => $ip,
  }
  ini_setting { 'puppet.conf/master/dns_alt_names':
    ensure => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'master',
    setting => 'dns_alt_names',
    value   => "${ip}, puppet, puppet.local, ${fqdn}, localhost",
  }
  ini_setting { 'puppet.conf/master/hiera_config':
    ensure => present,
    path    => '/etc/puppet/puppet.conf',
    section => 'master',
    setting => 'hiera_config',
    value   => '$manifestdir/hiera.yaml',
  }

  firewall{
    "0100-INPUT ACCEPT 8081400":
    action => 'accept',
    dport  => 8140,
    proto  => 'tcp'
  }
}
