# === Class bind::params ===
#
class bind::params {

  case $facts['os']['family'] {
    'RedHat': {
      $package_name = 'bind'
      $service_name = 'named'
      $cfgdir       = '/etc/named'
      $cfgfile      = '/etc/named.conf'
      $keyfile      = '/etc/rndc.key'
      $datadir      = '/var/named'
    }
    default: {
      fail('Sorry! Your OS is not supported.')
    }
  }

  $acl_trusted   = ['localnets']
  $acl_bogon     = []
  $forwarders    = []
  $listen_ip     = ['0.0.0.0']
  $listen_port   = 53
  $notify_slaves = 'yes'
  $int_zones_list = "${cfgdir}/internal.zones"
  $ext_zones_list = "${cfgdir}/external.zones"
}
