#
class bind::service inherits bind {

  $_service_name = $chroot ?
  {
    true  => $service_name_chroot,
    false => $service_name
  }

  service { $_service_name:
    ensure => $ensure ? { 'present' => 'running', 'absent' => undef },
    enable => $ensure ? { 'present' => true, 'absent' => undef },
  }
}
