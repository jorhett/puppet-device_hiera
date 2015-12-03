# Class: device_hiera::interfaces
# ===============================
#
# Utilize Hiera data to simplify Network Device interface configuration.
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
#  This contains a hash of default interface configuration values 
#  gathered from Hiera data merge.
#
# * `$ports`
#  This contains a hash with String keys named for slot names,
#  and String values containing a range of port numbers.
#
# * `$custom`
#  This contains a hash with String keys for interface names 
#  that receive custom configuration. Values are another hash
#  of configuration settings.
#
# Examples
#
# @example Hiera configuration for device_hiera::interfaces
#
#  classes:
#  - device_hiera::interfaces
#
#  device_hiera::interfaces::default:
#    description: 'Default configuration'
#    mode: 'dynamic auto'
# 
#  device_hiera::interfaces::ports:
#    'FastEthernet0': '1-24'
#    'GigabitEthernet0': '1-2'
# 
#  device_hiera::interfaces::custom:
#    'GigabitEthernet0/3':
#      description: 'Uplink to core'
#      mode: 'trunk'
#
class device_hiera::interfaces {

  $defaults = hiera_hash( 'device_hiera::interfaces::default', {} )
  $ports = hiera_array( 'device_hiera::interfaces::ports', {} )
  $custom = hiera_hash( 'device_hiera::interfaces::custom', {} )

  $ports.each() |$slot| {
    $slot.each() |$prefix,$ports| {
      $range = $ports.scanf('%i-%i') |$values| {
        $min = $values[0]
        $max = $values[1]
        notice( $min, $max )
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
      notice( "port range: $prefix/${range[0]} - $prefix/${range[1]}" )

      Integer[ $range[0], $range[1] ].each |$portnum| {
        $intname = "${prefix}/${portnum}"
        # If we don't have a specific, give it default config
        if $custom[$intname] == undef {
          $reshash = { $intname => $defaults, }
          notice( $reshash )
          create_resources( interface, $reshash )
        }
      }
    }
  }

  create_resources( interface, $custom, $defaults )
}
