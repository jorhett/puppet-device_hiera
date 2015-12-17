# device_hiera

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with device_hiera](#setup)
    * [What device_hiera affects](#what-device_hiera-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

TL;DR - DRY network device configuration

Network device configuration (e.g. Cisco, Juniper, Arista, etc)
using individual resources is messy and repetitive. This module takes advantage of 
Hiera hierarchies and hash merging to simplify and centralize network device 
configuration.

This module can reduce the configuration of a distribution campus switch environment
from thousands of lines to a few dozen.

## Module Description

Device Hiera makes uses of Hiera data and Hiera hierarchies to provide complete
network device configurations with a DRY and minimal data input format. This
module does no implementation, it simply utilizes Hiera's hash merging capabilities
to creates the appropriate device-specific resources.

## Setup

No setup required other than 

* define the Hiera data for each type as documented
* ensure that you've installed modules which provide the device resource you want
  (e.g. anything other than `vlan` and `interface`)

### Setup Requirements

Define Hiera data as documented here or in the module examples.

## Usage

List the resource types you wish to load from Hiera data.

* `interfaces` to provide slots and port ranges (notice plural)
* `vlan` to manage vlans
* ...any other type provided by modules you have installed

Declare the base class, and list the resource types which should be used from Hiera.

```
classes:
  - device_hiera

device_hiera::resources:
  - vlan
  - interfaces
```

For each resource type you can define defaults which will be used if not overridden
in the specific definition. For example, interface definition:

```
device_hiera::defaults::interface:
  description  : 'Default interface configuration'
  mode         : 'dynamic auto'
  encapsulation: 'negotiate'
  access_vlan  : '200'
```

Interfaces are special because we provide the ability to list slots in the chassis
along with a list of ports, which obviously the interface parameter doesn't handle.

First define an array which contains a single key of the slot name,
and a value containing a single range of ports MIN-MAX. The slot can defined multiple times.

```
device_hiera::interfaces::ports:
  - 'FastEthernet0'     : '2-23'
  - 'GigabitEthernet1/0': '1-2'
  - 'GigabitEthernet1/0': '5-6'
```

Then define the custom parameters for any port with a non-default configuration.
These ports can fall inside or outside of the slots and ranges supplied above.

```
device_hiera::interfaces::custom:
  'GigabitEthernet1/0/3':
     description  : 'Uplink to core'
     mode         : 'trunking'
     encapsulation: 'dot1q'
     native_vlan  : 200
```

Any other resource type can also be created with parameters supplied in a hash under their title.
They can likewise fall back on default values for the type.

Values for the resource types and parameters should be taken from the module which provides the resource type in question.
Documentation for the vlan type used below can be found at https://docs.puppetlabs.com/references/latest/type.html#vlan

```
device_hiera::resources:
  - vlan

device_hiera::defaults::vlan:
  ensure: present

device_hiera::vlan:
  200: 
    description: 'vlan200_Funtime :'
  400: 
    description: 'vlan400_fail'

```

For another example, if you have installed the `puppetlabs/ciscopuppet` module, you could use this for OSPF configuration:

```
device_hiera::resources:
  - cisco_interface_ospf

device_hiera::defaults::cisco_interface_ospf:
  ensure: present
  cost  : 200
  ospf  : default

device_hiera::cisco_interface_ospf:
  'Ethernet1/2 default': 
    area: '172.16.0.0'
```

### What device_hiera affects

* Uses Hiera hierarchy and data merging to simplify multiple device configuration
* Allows definition of port defaults which reduces repetitive data entry (DRY)
* Can be used with any network device vendor

...etc

## Limitations

You will need to include any vendor-specific modules necessary to implement
the resources created by device_hiera.

## Development

Any and all patches or features welcome and encouraged.

