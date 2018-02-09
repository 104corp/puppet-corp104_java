class corp104_java::install::oracle_jdk inherits corp104_java {
  case $facts['os']['family'] {
    'Debian': {
      case $corp104_java::jdk_version {
        '8' : {
          $package_name = 'oracle-java8-set-default'
          $java_home    = '/usr/lib/jvm/java-8-oracle'
        }
        '9' : {
          $package_name = 'oracle-java9-set-default'
          $java_home    = '/usr/lib/jvm/java-9-oracle'
        }
        default : {
          fail ("unsupported oracle_jdk 1.${corp104_java::jdk_version} version at ${facts['os']['family']}")
        }
      }

      $add_apt_package = [ 'python-software-properties', 'software-properties-common' ]
      package { $add_apt_package:
        ensure => present,
        # notify => Exec['install-ppa'],
      }

      if $corp104_java::http_proxy {
        exec { 'install-ppa':
          path        => '/bin:/usr/sbin:/usr/bin:/sbin',
          environment => [
            "http_proxy=${corp104_java::http_proxy}",
            "https_proxy=${corp104_java::http_proxy}",
          ],
          command     => "add-apt-repository -y ${corp104_java::ppa_oracle} && apt-get update",
          user        => 'root',
          notify      => Exec['set-licence-select','set-licence-seen'],
          unless      => 'apt-cache policy | grep webupd8team',
        }
      }
      else {
        exec { 'install-ppa':
          path    => '/bin:/usr/sbin:/usr/bin:/sbin',
          command => "add-apt-repository -y ${corp104_java::ppa_oracle} && apt-get update",
          user    => 'root',
          notify  => Exec['set-licence-select','set-licence-seen'],
          unless  => 'apt-cache policy | grep webupd8team',
        }
      }

      exec { 'set-licence-select':
        path        => '/bin:/usr/sbin:/usr/bin:/sbin',
        command     => "echo ${package_name} shared/accepted-oracle-license-v1-1 select true | debconf-set-selections",
        refreshonly => true,
        unless      => "debconf-show ${package_name} | grep shared/accepted-oracle-license-v1-1",
      }

      exec { 'set-licence-seen':
        path        => '/bin:/usr/sbin:/usr/bin:/sbin',
        command     => "echo ${package_name} shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections",
        refreshonly => true,
        unless      => "debconf-show ${package_name} | grep shared/accepted-oracle-license-v1-1",
      }

      package { 'install_oraclejdk':
        ensure  => present,
        name    => $package_name,
        require => Exec['install-ppa','set-licence-select','set-licence-seen'],
      }
    }
    'Redhat': {
      case $corp104_java::jdk_version {
        '8' : {
          $oraclejdk_download_url = 'http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163'
          $package_name = 'jdk1.8.0_131'
          $package_rpm  = 'jdk-8u131-linux-x64.rpm'
          $java_home    = '/usr/java/default'
        }
        default : {
          fail ("unsupported oracle_jdk 1.${corp104_java::jdk_version} version at ${$facts['os']['family']}")
        }
      }

      if $corp104_java::http_proxy {
        exec { 'download_oraclejdk':
          command => "/usr/bin/curl -x ${corp104_java::http_proxy} -L -H '${corp104_java::oraclejdk_verify_cookie}' --connect-timeout ${corp104_java::proxy_download_timeout} -o ${corp104_java::oraclejdk_rpm} -O ${oraclejdk_download_url}/${package_rpm}",
          unless  => "/bin/rpm -qa | grep ${package_name}",
          notify  => Exec['install_oraclejdk'],
        }
      }
      else {
        exec { 'download_oraclejdk':
          command => "/usr/bin/curl -L -H '${corp104_java::oraclejdk_verify_cookie}' -o ${corp104_java::oraclejdk_rpm} --connect-timeout ${corp104_java::proxy_download_timeout} -O ${oraclejdk_download_url}/${package_rpm}",
          unless  => "/bin/rpm -qa | grep ${package_name}",
          notify  => Exec['install_oraclejdk'],
        }
      }

      exec { 'install_oraclejdk':
        command     => "/bin/rpm -ivh ${corp104_java::oraclejdk_rpm}",
        subscribe   => Exec['download_oraclejdk'],
        refreshonly => true
      }

    }
    default : {
      fail ("unsupported platform ${$facts['osfamily']}")
    }
  }

  augeas { 'java-home-environment':
    lens    => 'Shellvars.lns',
    incl    => '/etc/environment',
    changes => "set JAVA_HOME ${java_home}",
  }
}
