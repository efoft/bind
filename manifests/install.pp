#
class bind::install inherits bind {

  $_package_name = $chroot ? { true => "${package_name}-chroot", false => $package_name }

  package { $_package_name:
    ensure => $ensure ? { 'present' => 'present', 'absent' => 'purged' }
  }
}
