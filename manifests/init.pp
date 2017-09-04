# Class: corp104_java
# ===========================
#
# Full description of class corp104_java here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'corp104_java':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class corp104_java (
  String $jdk_type,
  String $jdk_version,
  String $proxy_download_timeout,
  String $oraclejdk_rpm,
  String $ppa_openjdk,
  String $ppa_oracle,
  String $oraclejdk_verify_cookie,
  Optional[String] $http_proxy,
){
  contain corp104_java::install
  contain corp104_java::config

  Class['::corp104_java::install']
  -> Class['::corp104_java::config']
}
