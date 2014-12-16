# Dependencies

* puppetlabs/puppetdb
* puppetlabs/firewall
* puppetlabs/inifile
* puppetlabs/stdlib

# Example

```
class{
  '::puppetmaster'
    ip => $::ipaddress_eth1
}
```