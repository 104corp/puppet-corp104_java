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
        default : {
          fail ("unsupported openjdk 1.${corp104_java::jdk_version} version at ${facts['osfamily']}")
        }
      }

      $add_apt_package = [ 'python-software-properties', 'software-properties-common' ]
      package { $add_apt_package:
        ensure => present,
        notify => Exec['install-ppa'],
      }

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
        default : {
          fail ("unsupported openjdk 1.${corp104_java::jdk_version} version at ${$facts['osfamily']}")
        }
      }
    }
    default: {
      fail ("unsupported platform ${facts['os']['family']}")
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
