# === Define bind::zone ===
#
define bind::zone (
  String $zonename                                                           = $title,
  Enum['internal','external'] $view,
  Enum['master','slave'] $type                                               = 'master',
  Optional[Array[Stdlib::Ip::Address]] $masters                              = undef,
  Optional[Array[Stdlib::Ip::Address]] $slaves                               = undef,
  Optional[Array[Variant[Stdlib::Ip::Address,Enum['localhost']]]] $updaters  = undef,
  Boolean $update_by_key                                                     = false,
  Boolean $replace                                                           = false,
  Numeric $ttl                                                               = 86400,
  String $soa_mastername                                                     = $facts['networking']['fqdn'],
  String $soa_hostmaster                                                     = 'hostmaster',
  Variant[String,Numeric] $refresh                                           = '1D',
  Variant[String,Numeric] $retry                                             = '15M',
  Variant[String,Numeric] $expire                                            = '1W',
  Variant[String,Numeric] $minimum                                           = '1D',
  Tuple $records                                                             = [],
) {

  if $type == 'slave' and ! $masters {
    fail('Masters list must be defined for slave type zone.')
  }

  if $view == 'external' {
    realize(Concat::Fragment['named.conf-external-view'])
  }

  if $type == 'master' and empty($records) {
    fail('Zone must have at least NS records')
  }

  concat::fragment { "${zonename}-in-${view}.zones":
    target  => $view ? { 'internal' => $bind::params::int_zones_list, 'external' => $bind::params::ext_zones_list },
    content => template('bind/list.zones.erb'),
    order   => '02',
  }

  if $type == 'master' {
    file { "${bind::params::datadir}/${view}/${zonename}":
      ensure  => file,
      owner   => ($update_by_key or $updaters) ? { true => 'named', false => 'root' }, # prevent modification if no updaters
      group   => 'named',
      mode    => '0640',
      content => template('bind/zonefile.erb'),
      replace => $replace,
      notify  => Service[$bind::service::service_name],
    }
  }
}
