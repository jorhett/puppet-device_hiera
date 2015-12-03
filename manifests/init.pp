# Class: device_hiera
# ===========================
#
# Utilize Hiera data to simplify Network Device configuration.
#
# Parameters
# ----------
#
# None in base class.
#
# Variables
# ----------
#
# None in base class.
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
class device_hiera {

  contain device_hiera::interfaces

}
