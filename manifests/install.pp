class corp104_java::install inherits corp104_java {
  if $corp104_java::jdk_type == 'oraclejdk' {
    include corp104_java::install::oracle_jdk
  }
  elsif $corp104_java::jdk_type == 'openjdk' {
    include corp104_java::install::open_jdk
  }
  else {
    fail ("unsupported jdk type ${corp104_java::jdk_type}")
  }
}