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

Utilize Hiera data and default port configurations to simplify 
network device (e.g. Cisco, Juniper, Arista, etc) configuration.

## Module Description

Device Hiera makes uses of Hiera data and Hiera hierarchies to provide complete
network device configurations with a DRY and minimal data input format. This
module does no implementation, it simply creates appropriate device-specific
resources from the data provided.

## Setup

### What device_hiera affects

* Uses Hiera hierarchy and data merging to simplify multiple device configuration
* Allows definition of port defaults which reduces repetitive data entry (DRY)
* Can be used with any network device vendor

### Setup Requirements

Define Hiera data as documented in the modules.

## Usage

Include the appropriate classes for the device resources you wish to manage.

* `device_hiera::interfaces` to manage network ports
* `device_hiera::vlans` to manage vlans

...etc

## Limitations

You will need to include any vendor-specific modules necessary to implement
the resources created by device_hiera.

## Development

Any and all patches or features welcome and encouraged.

