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
#  - device_hiera
#  
#  device_hiera::resources:
#  - interfaces
#
#  device_hiera::defaults::interface:
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

  # Determine the default interface profile
  $defaults = hiera_hash( 'device_hiera::defaults::interface', {} )

  # make duplicate profile without unused VLAN settings
  if $defaults['mode'] == 'access' {
    $clean_defaults = $defaults - ['native_vlan','encapsulation']
  }
  elsif $defaults['mode'] == 'trunk' {
    $clean_defaults = $defaults - ['access_vlan']
  }
  else {
    $clean_defaults = $defaults
  }

  # Now get a list of ports
  $ports = hiera_array( 'device_hiera::interfaces::ports', {} )
  $custom = hiera_hash( 'device_hiera::interfaces::custom', {} )

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
        # If the port doesn't have a custom config, give it the default config
        $intname = "${prefix}/${portnum}"
        if $custom[$intname] == undef {
          $reshash = { $intname => $clean_defaults, }
          create_resources( interface, $reshash )
        }
      }
    }
  }

  # Process all customized port configs
  $custom.each() |$interface,$intconfig| {
    # avoid messy vlan settings irrelevant to the port
    notice( "mode = ${intconfig['mode']}" )
    if( $intconfig['mode'] == undef and $defaults['mode'] == 'access' ) or ($intconfig['mode'] == 'access' ) {
      $final_config = $intconfig - ['native_vlan','encapsulation']
      $clean_defaults = $defaults - ['native_vlan','encapsulation','description']
    }
    elsif( $intconfig['mode'] == undef and $defaults['mode'] == 'trunk' ) or ($intconfig['mode'] == 'trunk' ) {
      $final_config = $intconfig - ['access_vlan']
      $clean_defaults = $defaults - ['access_vlan','description']
    }
    else {
      $final_config = $intconfig
      $clean_defaults = $defaults - ['description']
    }
    notice( "config = ${final_config}" )
    notice( "defaults = ${clean_defaults}" )
    # Now create the resource
    $reshash = { $interface => $final_config, }
    create_resources( interface, $reshash, $clean_defaults )
  }
}
