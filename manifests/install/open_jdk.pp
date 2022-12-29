class corp104_java::install::open_jdk inherits corp104_java {
  case $facts['os']['family'] {
    'Debian': {
      case $corp104_java::jdk_version {
        '7' : {
          $package_name = 'openjdk-7-jre'
          $java_home    = '/usr/lib/jvm/java-7-openjdk-amd64'
        }
        '8' : {
          $package_name = 'openjdk-8-jre'
          $java_home    = '/usr/lib/jvm/java-8-openjdk-amd64'
        }
        '9' : {
          $package_name = 'openjdk-9-jre'
          $java_home    = '/usr/lib/jvm/java-9-openjdk-amd64'
        }
        '10' : {
          $package_name = 'openjdk-10-jre'
          $java_home    = '/usr/lib/jvm/java-10-openjdk-amd64'
        }
        '11' : {
          $package_name = 'openjdk-11-jre'
          $java_home    = '/usr/lib/jvm/java-11-openjdk-amd64'
        }
        '17' : {
          $package_name = 'openjdk-17-jre'
          $java_home    = '/usr/lib/jvm/java-17-openjdk-amd64'
        }
        default: {
          fail("unsupported openjdk 1.${corp104_java::jdk_version} version at ${$facts['os']['family']}")
        }
      }

      # remove python-software-properties that only support for ubuntu <= 12.04
      # replace it with software-python-common for ubuntu >= 12.10
      $add_apt_package = [ 'software-properties-common' ]
      package { $add_apt_package:
        ensure => present,
        notify => Exec['install-ppa'],
      }

      if $corp104_java::http_proxy {
        exec { 'install-ppa':
          path        => '/bin:/usr/sbin:/usr/bin:/sbin',
          environment => [
            "http_proxy=${corp104_java::http_proxy}",
            "https_proxy=${corp104_java::http_proxy}",
          ],
          command     => "add-apt-repository -y ${corp104_java::ppa_openjdk} && apt-get update",
          user        => 'root',
          unless      => "/usr/bin/dpkg -l | grep ${package_name}",
          before      => Package[$package_name],
        }
      }
      else {
        exec { 'install-ppa':
          path    => '/bin:/usr/sbin:/usr/bin:/sbin',
          command => "add-apt-repository -y ${corp104_java::ppa_openjdk} && apt-get update",
          user    => 'root',
          unless  => "/usr/bin/dpkg -l | grep ${package_name}",
          before  => Package[$package_name],
        }
      }
    }
    'Redhat': {
      case $corp104_java::jdk_version {
        '6' : {
          $package_name = 'java-1.6.0-openjdk'
          $java_home    = '/usr/lib/jvm/jre-1.6.0-openjdk.x86_64'
        }
        '7' : {
          $package_name = 'java-1.7.0-openjdk'
          $java_home    = '/usr/lib/jvm/jre-1.7.0-openjdk.x86_64'
        }
        '8' : {
          $package_name = 'java-1.8.0-openjdk'
          $java_home    = '/usr/lib/jvm/jre-1.8.0-openjdk.x86_64'
        }
        default: {
          fail("unsupported openjdk 1.${corp104_java::jdk_version} version at ${$facts['os']['family']}")
        }
      }
    }
    default: {
      fail("unsupported platform ${$facts['os']['family']}")
    }
  }

  augeas { 'java-home-environment':
    lens    => 'Shellvars.lns',
    incl    => '/etc/environment',
    changes => "set JAVA_HOME ${java_home}",
  }

  package { $package_name:
    ensure => installed,
  }
}
