# === Class bind::config ===
#
class bind::config {

  assert_private('This is private class')

  $ensure         = $bind::ensure
  $chroot         = $bind::chroot
  $acl_trusted    = $bind::acl_trusted
  $acl_bogon      = $bind::acl_bogon
  $acls           = $bind::acls
  $listen_port    = $bind::listen_port
  $listen_ip      = $bind::listen_ip
  $forwarders     = $bind::forwarders
  $forward        = $bind::forward
  $notify_slaves  = $bind::notify_slaves
  $check_names    = $bind::check_names
  $dnssec_enable  = $bind::dnssec_enable
  $extra_options  = $bind::extra_options
  $datadir        = $bind::params::datadir
  $int_zones_list = $bind::params::int_zones_list
  $ext_zones_list = $bind::params::ext_zones_list

  if $ensure == 'present' {
    exec { 'create-rndckey-file':
      command         => 'rndc-confgen -a -k "rndc-key" -r /dev/urandom',
      path            => [ '/usr/sbin', '/usr/bin' ],
      creates         => $bind::params::keyfile,
      require         => Package[$bind::install::package_name],
    }
  }

  Concat {
    ensure  => $ensure,
    owner   => 'root',
    group   => 'named',
    mode    => '0640',
  }

  File {
    owner   => 'root',
    group   => 'named',
  }

  file { $bind::params::keyfile:
    ensure  => $ensure,
    mode    => '0640',
    require => $ensure ? { 'present' => Exec['create-rndckey-file'], 'absent' => undef },
  }

  file { ["${bind::params::datadir}/internal", "${bind::params::datadir}/external"]:
    ensure  => $ensure ? { 'present' => 'directory', 'absent' => 'absent' },
    mode    => '0770',
    force   => true,
    recurse => true,
    purge   => true,
  }

  concat { $bind::params::cfgfile: }
  concat { $bind::params::int_zones_list: }
  concat { $bind::params::ext_zones_list: }

  concat::fragment {
    "puppet-managed-header-${bind::params::int_zones_list}":
      target => $bind::params::int_zones_list,
      source => 'puppet:///modules/bind/puppet-managed-header.txt',
      order  => '01';
    "puppet-managed-header-${bind::params::ext_zones_list}":
      target => $bind::params::ext_zones_list,
      source => 'puppet:///modules/bind/puppet-managed-header.txt',
      order  => '01';
    'named.conf-till-external-view':
      target  => $bind::params::cfgfile,
      content => template('bind/named.conf.erb'),
      order   => '01';
  }

  @concat::fragment { 'named.conf-external-view':
    target  => $bind::params::cfgfile,
    content => template('bind/named.conf.ext_view.erb'),
    order   => '02',
  }

  create_resources('bind::zone', $bind::zones)
}
