##2015-12-16 - Release 0.2.1
###Summary
####Bugfixes

- Don't pass VLAN parameters which won't be used through 
- Don't use default description on custom ports

##2015-12-16 - Release 0.2.0
###Summary

Altered configuration to generate any resource type based on Hiera input.
Define the list of resources using `resources` array parameter

####Features

- Support all resource types with defaults and hash merging

##2015-12-15 - Release 0.1.1
###Summary

Added support for VLAN hash merge from Hiera

####Features

- VLAN hash merge to combine all local VLANs

####Bugfixes

- Return slots to an array so as to allow multiple line definitions

##2015-12-03 - Release 0.1.0
###Summary

Allow DRY configuration of network interface ports from Hiera.

####Features

- Default interface configuration
- Short list of Slots/Ports to be configured
- Small (DRY) list of customized ports
