#
class bind::params {

  case $facts['os']['family'] {
    'RedHat': {
      $package_name        = 'bind'
      $cfgdir              = '/etc/named'
      $cfgfile             = '/etc/named.conf'
      $keyfile             = '/etc/rndc.key'
      $datadir             = '/var/named'
      $service_name        = 'named'
      $service_name_chroot = $::operatingsystemmajrelease ?
      {
        '6' => $service_name,
        '7' => "${service_name}-chroot",
      }
    }
    default: {
      fail('Sorry! Your OS is not supported.')
    }
  }

  $acl_trusted   = ['localnets']
  $acl_bogon     = []
  $listen_port   = 53
  $notify_slaves = 'yes'
  $int_zones_list = "${cfgdir}/internal.zones"
  $ext_zones_list = "${cfgdir}/external.zones"
}
