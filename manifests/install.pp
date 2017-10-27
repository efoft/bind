# === Class bind::install ===
#
class bind::install {

  assert_private('This is private class')

  $package_name = $bind::chroot ? { true => "${bind::params::package_name}-chroot", false => $bind::params::package_name }

  package { $package_name:
    ensure => $bind::ensure ? { 'absent' => 'purged', default => $ensure }
  }
}
