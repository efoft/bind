# === Class bind ===
#
# Installs and confugures isc-bind (optionally in chroot mode) as well as zone files.
# Configuration uses views.
#
# === Parameters ===
# [*ensure*]
#   Set to absent to remove.
#
# [*chroot*]
#   If to run bind in chroot mode.
#   Default: true
#
# [*trusted*]
#   Array containing IP addresses of host and networks (with prefix) that permitted to query this server.
#   This list belongs to 'internal' view. It also may contain special words:
#     - localnets: matches IP address of any locally connected network
#     - none: matches no IP address
#   Do not include 'localhost' into this list since it's already included in .erb file and matches any IP
#   used by local system.
#
# [*bogon*]
#   Black list ACL.
#   Default: empty
#
# [*acls*]
#   Hash of access control lists.
#   Example:
#     some-ips:
#       X.X.X.X
#       Y.Y.Y.Y/ZZ
#   These acls can be later referenced in zones configuration.
#
# [*listen_port*]
#   Tcp port on which bind listens.
#   Default: 53
#
# [*listen_ip*]
#   Array of IP addresses no which to listen. If undef, bind will listen on 0.0.0.0/0.
#   Default: ['127.0.0.1']
#
# [*forwarders*]
#   Specifies an array of IP addresses for nameservers where requests should be forwarded for resolution.
#
# [*forward*]
#   Specifies the forwarding behavior of a forwarders directive. The following options are accepted:
#     - first: nameservers listed in the *forwarders* be queried before named attempts to resolve the name itself
#     - only:  named does not attempt name resolution itself if quering *forwarders* fail
#
# [*notify*]
#   Controls whether named notifies the slave servers when a zone is updated. It accepts the following options:
#   - yes
#   - no
#   - explicit: only notifies slave servers specified in an also-notify list within a zone statement
#
# [*check_names*]
#   What to do if nasty chars (like underscore) are found in zone names.
#   Values can be:
#   - ignore (useful for MS AD zones)
#   - warn
#   - fail (default in bind if directive is omitted)
#
# [*dnssec_enable*]
#   DNS Security Extensions (DNSSEC) is a specification which aims at maintaining the data integrity of DNS responses.
#   DNSSEC signs all the DNS resource records (A, MX, CNAME etc.) of a zone using PKI (Public Key Infrastructure).
#   Default: true
#
# [*extra_options*]
#   Put here as a hash everything that is not in class parameters.
#
# [*zones*]
#   See parameters in bind::zone.
#   Example of hash (hiera format):
#   ---
#   zones:
#     example.com:
#       view: internal
#       replace: true
#       records:
#         - type: NS
#           name: pup4test
#         - type: MX
#           priority: 10
#           value: pup4test
#         - type: A
#           name: pup4test
#           value: 10.1.1.100
#     test.com:
#       view: internal
#       updaters: ['10.1.1.200']
#       update_by_key: true
#       records:
#         - type: NS
#           name: pup4test
#         - type: A
#           name: pup4test
#           value: 10.1.1.100
#     test.net:
#       type: slave
#       view: external
#       masters: ['192.168.1.200']
#       update_by_key: true
#
class bind (
  Enum['present','absent'] $ensure                    = 'present',
  Boolean $chroot                                     = true,
  Array $acl_trusted                                  = $bind::params::acl_trusted,
  Array $acl_bogon                                    = $bind::params::acl_bogon,
  Hash $acls                                          = {},
  Numeric $listen_port                                = $bind::params::listen_port,
  Optional[Array[Stdlib::Ip_address]] $listen_ip      = $bind::params::listen_ip,
  Array[Stdlib::Ip::Address] $forwarders              = $bind::params::forwarders,
  Enum['first','only'] $forward                       = 'first',
  Enum['yes','no','explicit'] $notify_slaves          = $bind::params::notify_slaves,
  Optional[Enum['ignore','warn','fail']] $check_names = undef,
  Boolean $dnssec_enable                              = true,
  Hash $extra_options                                 = {},
  Hash $zones                                         = {},
) inherits bind::params {

  class{ 'bind::install': } ->
  class{ 'bind::selinux': } ->
  class{ 'bind::config':  } ~>
  class{ 'bind::service': }
}
