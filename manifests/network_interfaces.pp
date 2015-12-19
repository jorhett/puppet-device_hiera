# Class: device_hiera::network_interfaces
# =======================================
#
# Utilize Hiera data to simplify NetDev network_interface configuration.
#
# Parameters
# ----------
#
# None yet.
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `$defaults`
#  This contains a hash of default network_interface configuration values 
#  gathered from Hiera data merge.
#
# * `$ports`
#  This contains a hash with String keys named for slot names,
#  and String values containing a range of port numbers.
#
# * `$custom`
#  This contains a hash with String keys for network_interface names 
#  that receive custom configuration. Values are another hash
#  of configuration settings.
#
# Examples
#
# @example Hiera configuration for device_hiera::network_interfaces
#
#  classes:
#  - device_hiera
#  
#  device_hiera::resources:
#  - network_interfaces
#
#  device_hiera::defaults::network_interface:
#    duplex: 'full'
#    enable: 'true'
#    mtu   : '1500'
# 
#  device_hiera::network_interfaces::ports:
#    - 'GigabitEthernet': '1-48'
# 
#  device_hiera::network_interfaces::custom:
#    'TenGigabitEthernet01':
#      description: 'Uplink to core'
#      speed: '10g'
#
class device_hiera::network_interfaces(
) {

  # Determine the default network_interface profile
  $defaults = hiera_hash( 'device_hiera::defaults::network_interface', {} )

  # Now get a list of ports
  $ports = hiera_array( 'device_hiera::network_interfaces::ports', {} )
  $custom = hiera_hash( 'device_hiera::network_interfaces::custom', {} )

  # Process every listed port unless it has a custom config
  $ports.each() |$slot| {
    $slot.each() |$prefix,$ports| {
      $range = $ports.scanf('%i-%i') |$values| {
        $min = $values[0]
        $max = $values[1]
        unless $min > 0 {
          fail "Invalid port range #{ports}"
          [-1,-1]
        }
        unless $max >= $min {
          fail "Invalid port range #{ports}"
          [-1,-1]
        }
        [$min,$max]
      }

      Integer[ $range[0], $range[1] ].each |$portnum| {
        # assumes that prefix contains any necessary separator
        $intname = "${prefix}${portnum}"

        # If the port doesn't have a custom config, give it the default config
        if $custom[$intname] == undef {
          $reshash = { $intname => $defaults, }
          create_resources( network_interface, $reshash )
        }
      }
    }
  }

  # Process all customized port configs
  $custom.each() |$interface,$intconfig| {
    # don't duplicate description to custom port configs
    $clean_defaults = $defaults - ['description']

    # Now create the resource
    $reshash = { $interface => $intconfig, }
    create_resources( network_interface, $reshash, $clean_defaults )
  }
}
