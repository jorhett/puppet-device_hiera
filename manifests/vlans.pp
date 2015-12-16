# Class: device_hiera::vlans
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
# * `$vlans`
#  This contains a hash with numeric keys for the vlan tag (valid values 1-4094)
#  The value is another hash with attributes as defined at
#     https://docs.puppetlabs.com/references/latest/type.html#vlan
#
# Examples
#
# @example Hiera configuration for device_hiera::vlans
#
#  classes:
#  - device_hiera::vlans
#
#  device_hiera::vlans:
#    200:
#      ensure     : present
#      description: 'Office VLAN'
#    300:
#      ensure     : absent
#      description: 'no longer used'
#      
class device_hiera::vlans {
  $vlans = hiera_hash( 'device_hiera::vlans', {} )
  create_resources( vlan, $vlans )
}
