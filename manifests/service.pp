# === Class bind::service ===
#
class bind::service {

  $service_name = $::bind::chroot ?
  {
    true => $::operatingsystemmajrelease ?
    {
      '6' => $::bind::params::service_name,
      '7' => "${::bind::params::service_name}-chroot"
    },
    false => $::bind::params::service_name
  }

  service { $service_name:
    ensure => $::bind::ensure ? { 'present' => 'running', 'absent' => undef },
    enable => $::bind::ensure ? { 'present' => true, 'absent' => undef },
  }
}
