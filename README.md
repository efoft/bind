# puppet-bind module

Yet another attempt to automate BIND installation and configuration on RHEL-based Linux distros.

## Installation
Clone into puppet's modules directory:
```
git clone https://github.com/efoft/puppet-bind.git bind
```

## Example of usage
```
class { '::bind':
    listen_ip   => ['192.168.1.1'],
    acl_trusted => ['192.168.1.0/24'],
    check_names => 'ignore',
    zones       => $zones,
  }
```

Parameter 'zones' data can be stored in hiera e.g.:
```
zones:
  example.com:
    view: internal
    replace: true
    records:
      - type: NS
        name: pup4test
      - type: MX
        priority: 10
        value: pup4test
      - type: A
        name: pup4test
        value: 10.1.1.100
  test.com:
    view: internal
    updaters: ['10.1.1.200']
    update_by_key: true
    records:
      - type: NS
        name: pup4test
      - type: A
        name: pup4test
        value: 10.1.1.100
  test.net:
    type: slave
    view: external
    masters: ['192.168.1.200']
    update_by_key: true
```
