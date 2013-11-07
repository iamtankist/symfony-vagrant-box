# Class: toolkit::composer
#
# Creates global install of composer.phar, aliased as 'composer'
#
# Parameters:
#   $dir:
#     Installation directory (default: '/usr/local/bin')
#
# Requires: none
#
# Sample Usage:
# class { 'toolkit::composer': }
#

class toolkit::composer(
    $dir  = '/usr/local/bin'
){

    exec { 'composer_install':
        name => 'curl -s getcomposer.org/installer | php',
        cwd => '/usr/local/bin',
        creates => '/usr/local/bin/composer.phar',
        path => '/usr/bin'
    }

    exec { 'composer_permissions':
        name => 'chmod 777 composer.phar',
        cwd => '/usr/local/bin',
        path => '/bin'
    }

    exec { 'composer_link':
        name => 'ln -s composer.phar composer',
        cwd => '/usr/local/bin',
        creates => '/usr/local/bin/composer',
        path => '/bin'
    }

    exec { 'composer_selfupdate':
        name => 'php composer self-update',
        cwd => '/usr/local/bin',
        path => '/usr/bin'
    }

    Exec['composer_install']
    ->Exec['composer_permissions']
    ->Exec['composer_link']
    ->Exec['composer_selfupdate']

}
