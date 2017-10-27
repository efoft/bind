# === Class bind::selinux ===
#
class bind::selinux {

  selboolean { 'named_write_master_zones':
    persistent  => true,
    value => 'on',
  }
}
