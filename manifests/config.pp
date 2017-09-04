class corp104_java::config {
  file { '/tmp/test':
    ensure => file,
    owner  => root,
    group  => root,
  }
}