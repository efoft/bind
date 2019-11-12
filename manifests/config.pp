#
class bind::config inherits bind {

  if $ensure == 'present' {
    exec { 'create-rndckey-file':
      command => 'rndc-confgen -a -k "rndc-key" -r /dev/urandom',
      path    => [ '/usr/sbin', '/usr/bin' ],
      creates => $keyfile,
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

  file { $keyfile:
    ensure  => $ensure,
    mode    => '0640',
    require => $ensure ? { 'present' => Exec['create-rndckey-file'], 'absent' => undef },
  }

  file { ["${datadir}/internal", "${datadir}/external"]:
    ensure  => $ensure ? { 'present' => 'directory', 'absent' => 'absent' },
    mode    => '0770',
  }

  concat { $cfgfile: }
  concat { $int_zones_list: }
  concat { $ext_zones_list: }

  concat::fragment {
    "puppet-managed-header-${int_zones_list}":
      target => $int_zones_list,
      source => 'puppet:///modules/bind/puppet-managed-header.txt',
      order  => '01';
    "puppet-managed-header-${ext_zones_list}":
      target => $ext_zones_list,
      source => 'puppet:///modules/bind/puppet-managed-header.txt',
      order  => '01';
    'named.conf-till-external-view':
      target  => $cfgfile,
      content => template('bind/named.conf.erb'),
      order   => '01';
  }

  @concat::fragment { 'named.conf-external-view':
    target  => $cfgfile,
    content => template('bind/named.conf.ext_view.erb'),
    order   => '02',
  }

  if $ensure == 'present' {
    create_resources('bind::zone', $bind::zones)
  }
}
