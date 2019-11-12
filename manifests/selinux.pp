#
class bind::selinux inherits bind {

  selboolean { 'named_write_master_zones':
    persistent => true,
    value      => $ensure ? { 'present' => 'on', 'absent' => 'off' },
  }
}
