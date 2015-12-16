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
#    - 'FastEthernet0': '1-24'
#    - 'GigabitEthernet0': '1-2'
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

  # avoid messy vlan settings irrelevant to the port
  if $defaults['mode'] == 'access' {
    $clean_defaults = delete( $defaults, ['native_vlan','encapsulation'] )
  }
  elsif $defaults['mode'] == 'trunk' {
    $clean_defaults = delete( $defaults, 'access_vlan' )
  }
  else {
    $clean_defaults = $defaults
  }

  # First process all default port configs
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
        $intname = "${prefix}/${portnum}"
        # If we don't have a specific, give it default config
        if $custom[$intname] == undef {
          $reshash = { $intname => $clean_defaults, }
          create_resources( interface, $reshash )
        }
      }
    }
  }

  # Now process all customized port configs
  $custom_interfaces = $custom.each() |$interface,$intconfig| {
    # avoid messy vlan settings irrelevant to the port
    if( $intconfig['mode'] == undef and $defaults['mode'] == 'access' ) or ($intconfig['mode'] == 'access' ) {
      $finalconfig = delete( $intconfig, ['native_vlan','encapsulation'] )
      $clean_defaults = delete( $defaults, ['native_vlan','encapsulation'] )
    }
    elsif( $intconfig['mode'] == undef and $defaults['mode'] == 'trunk' ) or ($intconfig['mode'] == 'trunk' ) {
      $finalconfig = delete( $intconfig, ['access_vlan'] )
      $clean_defaults = delete( $defaults, ['access_vlan'] )
    }
    else {
      $finalconfig = $intconfig
      $clean_defaults = $defaults
    }
    # Now create the resource
    $reshash = { $interface => $finalconfig, }
    create_resources( interface, $reshash, $clean_defaults )
  }
}
