group { 'puppet':
    ensure => 'present',
}

exec{ 'apt-get update':
    path      => ['/usr/local/bin', '/usr/bin', '/bin'],
    logoutput => false,
}

package {
    'git-core':
        ensure => present;
    'vim':
        ensure => present;
    'iotop':
        ensure => present;
    'ant':
        ensure => present;
    'acl':
        ensure => present;        
}

#### PHP+FPM+NGINX
class { 'nginxphp::ppa': 
}

include nginxphp

class { 'nginxphp::php':
  php_packages => [
    "php5-intl",
    "php5-curl",
    "php5-gd",
    "php5-xcache",
    "php5-mcrypt",
    "php5-xmlrpc",
    "php5-xsl",
    'php5-mysql',
  ]
}

include nginxphp::nginx

nginxphp::fpmconfig { $vagrant_project_name:
  php_devmode   => true,
  fpm_user      => 'www-data',
  fpm_group     => 'www-data',
  fpm_allowed_clients => ''
}

nginxphp::nginx_addphpconfig { $vagrant_project_name:
  website_root       => "${vagrant_project_root}/${vagrant_project_name}/web",
  default_controller => "app_dev.php",
  require => Nginxphp::Fpmconfig[$vagrant_project_name]
}

#### PHP configuration
augeas { "fpm-php.ini_php":
  context => "/files/etc/php5/fpm/php.ini/PHP",
  changes => [
    "set post_max_size 10M",
    "set upload_max_filesize 10M",
    "set display_errors On",
    "set short_open_tag Off",
  ];
}

augeas { "fpm-php.ini_date":
  context => "/files/etc/php5/fpm/php.ini/Date",
  changes => [
    "set date.timezone Europe/Berlin",
  ];
}

augeas { "cli-php.ini_php":
  context => "/files/etc/php5/cli/php.ini/PHP",
  changes => [
    "set post_max_size 10M",
    "set upload_max_filesize 10M",
    "set display_errors On",
    "set short_open_tag Off",
  ];
}

augeas { "cli-php.ini_date":
  context => "/files/etc/php5/cli/php.ini/Date",
  changes => [
    "set date.timezone Europe/Berlin",
  ];
}

#### MYSQL
class { 'mysql::server':
  config_hash => { 'root_password' => $vagrant_mysql_root }
}

#### Composer
class { 'toolkit::composer': }

#### Symfony
class { 'Symfony': 
  host_ip => $vagrant_host_ip,
  project_root => $vagrant_project_root,
  project_name => $vagrant_project_name,
}

Group['puppet']
->Exec['apt-get update']
->Package['git-core']
->Class['nginxphp::nginx']
->Augeas["fpm-php.ini_php"]
->Augeas["fpm-php.ini_date"]
->Augeas["cli-php.ini_php"]
->Augeas["cli-php.ini_date"]
->Class['toolkit::composer']
->Class['Symfony']