# Class: device_hiera
# ===========================
#
# Utilize Hiera data to simplify Network Device configuration.
#
# Parameters
# ----------
#
# @param [Array[String]] resources List of resources to process from Hiera
# * `resources`  
#   List of resources to process from Hiera
#    values: interfaces, vlan, ...
#
# Variables
# ----------
#
# * `has_subclass`  
#   Hash of resource types which have a subclass
#
# Examples
#
# @example Hiera configuration for device_hiera
#
#  classes:
#    - device_hiera
#
#  device_hiera::resources:
#    - interfaces 
#    - vlan 
#
#  device_hiera::vlan:
#    200:
#      ensure     : present
#      description: 'SF_Office_VLAN'
#    300:
#      ensure     : absent
#      description: 'formerly longer used'
#
##Authors
# @author Jo Rhett http://github.com/jorhett/puppet-device_hiera/issues
# Jo Rhett, Net Consonance
#  - report issues at http://github.com/jorhett/puppet-device_hiera/issues
#
##Copyright
# &copy; 2015 Net Consonance
# All Rights Reserved
#
class device_hiera(
  Array[String] $resources,
) {

  # Subclasses which are handled differently
  $has_subclass = {
    'interfaces' => true,
  }
  contain device_hiera::interfaces

  # Interate over the resource types provided
  $resources.each |$type| {
    if $has_subclass[$type] {
      # Include the subclass which processes those resources
      include "device_hiera::${type}"
    }
    else {
      # Look for default definition
      $defaults = hiera_hash( "device_hiera::defaults::${type}", {} )
      # Now get all the definitions for that type
      $objects = hiera_hash( "device_hiera::${type}", {} )
      # And create...
      create_resources( $type, $objects, $defaults )
    }
  }
}
