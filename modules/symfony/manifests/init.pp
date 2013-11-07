# Class: symfony
#
# Installs Symfony to a specific directory using composer
#
# Parameters:
#   $dir:
#     Installation directory (default: '/var/www/example')
#
# Requires: none
#
# Sample Usage:
# class { 'Symfony': }
#

class symfony (
    $project_root = '/var/www',
    $project_name = 'example',
    $version = '2.3.0',
    $host_ip = '127.0.0.1'
){

    file{ "${project_root}":
        ensure => 'directory',
        owner => 'vagrant',
        group => 'vagrant',
    }

    exec { 'symfony_install':
        name => "/usr/local/bin/composer create-project symfony/framework-standard-edition ${project_root}/${project_name} ${version}",
        cwd => "${project_root}",
        creates => "${project_root}/${project_name}",
        user => 'vagrant',
    }

    file { "build/permissions.sh" :
        path    => "${project_root}/${project_name}/build/permissions.sh",
        ensure  => present,
        content => template("symfony/build/permissions.sh"),
        mode    => '0755',
        owner => 'vagrant',
        group => 'vagrant',
        require => File["build"],
    }

    file { "build.xml" :
        path    => "${project_root}/${project_name}/build.xml",
        ensure  => present,
        content => template("symfony/build.xml"),
        owner => 'vagrant',
        group => 'vagrant',
        require => File["build/permissions.sh"],
        
    }

    file { "bin" :
        path    => "${project_root}/${project_name}/bin",
        ensure  => directory,
        owner => 'vagrant',
        group => 'vagrant',
        require => Exec['symfony_install'],
    }

    file { "build" :
        path    => "${project_root}/${project_name}/build",
        ensure  => directory,
        owner => 'vagrant',
        group => 'vagrant',#
        require => Exec["symfony_install"],
    }

    file { "build/ant" :
        path    => "${project_root}/${project_name}/build/ant",
        ensure  => directory,
        owner => 'vagrant',
        group => 'vagrant',
        require => File["build"],
    }

    file { "build/ant/build.xml" :
        path    => "${project_root}/${project_name}/build/ant/build.xml",
        ensure  => present,
        content => template("symfony/build/ant/build.xml"),
        owner => 'vagrant',
        group => 'vagrant',
        require => File["build/ant"],
    }

    file { "bin/apc_cc.php" :
        path    => "${project_root}/${project_name}/bin/apc_cc.php",
        ensure  => present,
        content => template("symfony/bin/apc_cc.php"),
        owner => 'vagrant',
        group => 'vagrant',
        require => File["bin"],
    }


    exec { 'symfony_permissions':
        name => "ant permissions",
        cwd => "${project_root}/${project_name}",
        path    => ["/bin", "/usr/bin", "/usr/sbin", "/usr/local/bin"],
        user => 'vagrant',
        require => File["build/ant/build.xml"]
    }

    exec { 'symfony_vendors':
        name => "composer install",
        cwd => "${project_root}/${project_name}",
        path    => ["/bin", "/usr/bin", "/usr/sbin", "/usr/local/bin"],
        user => 'vagrant',
        require => Exec["symfony_permissions"],
    }

    info "grep -w -c ${host_ip} ${project_root}/${project_name}/web/app_dev.php"

    exec { 'symfony_whitelist_dev': 
        name => "ant whitelist -Dip=\"${host_ip}\"",
        cwd => "${project_root}/${project_name}",
        path    => ["/bin", "/usr/bin", "/usr/sbin", "/usr/local/bin"],
        user => 'vagrant',
        require => Exec["symfony_vendors"],
        unless => [ 
            "grep -w -c ${host_ip} ${project_root}/${project_name}/web/app_dev.php", 
          ]
    }

}