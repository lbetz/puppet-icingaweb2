# @summary
#   Install and configure the director module.
#
# @note If you want to use `git` as `install_method`, the CLI `git` command has to be installed. You can manage it yourself as package resource or declare the package name in icingaweb2 class parameter `extra_packages`.
#
# @param ensure
#   Enable or disable module.
#
# @param module_dir
#   Target directory of the module.
#
# @param git_repository
#   Set a git repository URL.
#
# @param git_revision
#   Set either a branch or a tag name, eg. `master` or `v1.3.2`.
#
# @param install_method
#   Install methods are `git`, `package` and `none` is supported as installation method.
#
# @param package_name
#   Package name of the module. This setting is only valid in combination with the installation method `package`.
#
# @param db_type
#   Type of your database. Either `mysql` or `pgsql`.
#
# @param db_resource_name
#   Name for the director database resource.
#
# @param db_host
#   Hostname of the database.
#
# @param db_port
#   Port of the database.
#
# @param db_name
#   Name of the database.
#
# @param db_username
#   Username for DB connection.
#
# @param db_password
#   Password for DB connection.
#
# @param db_charset
#   Character set to use for the database.
#
# @param use_tls
#   Either enable or disable TLS encryption to the database. Other TLS parameters
#   are only affected if this is set to 'true'.
#
# @param tls_key_file
#   Location of the private key for client authentication. Only valid if tls is enabled.
#
# @param tls_cert_file
#   Location of the certificate for client authentication. Only valid if tls is enabled.
#
# @param tls_cacert_file
#   Location of the ca certificate. Only valid if tls is enabled.
#
# @param tls_key
#   The private key to store in spicified `tls_key_file` file. Only valid if tls is enabled.
#
# @param tls_cert
#   The certificate to store in spicified `tls_cert_file` file. Only valid if tls is enabled.
#
# @param tls_cacert
#   The ca certificate to store in spicified `tls_cacert_file` file. Only valid if tls is enabled.
#
# @param tls_capath
#   The file path to the directory that contains the trusted SSL CA certificates, which are stored in PEM format.
#   Only available for the mysql database.
#
# @param tls_noverify
#   Disable validation of the server certificate.
#
# @param tls_cipher
#   Cipher to use for the encrypted database connection.
#
# @param import_schema
#   Import database schema.
#
# @param kickstart
#   Run kickstart command after database migration. This requires `import_schema` to be `true`.
#
# @param endpoint
#   Endpoint object name of Icinga 2 API. This setting is only valid if `kickstart` is `true`.
#
# @param api_host
#   Icinga 2 API hostname. This setting is only valid if `kickstart` is `true`.
#
# @param api_port
#   Icinga 2 API port. This setting is only valid if `kickstart` is `true`.
#
# @param api_username
#   Icinga 2 API username. This setting is only valid if `kickstart` is `true`.
#
# @param api_password
#   Icinga 2 API password. This setting is only valid if `kickstart` is `true`.
#
# @param manage_service
#   If set to true the service (daemon) is managed.
#
# @param service_ensure
#   Wether the service is `running` or `stopped`.
#
# @param service_enable
#   Whether the service should be started at boot time.
#
# @param service_user
#   The user as which the service is running. Only valid if `install_method` is set to `git`.
#
# @note Please checkout the [Director module documentation](https://www.icinga.com/docs/director/latest/) for requirements.
#
# @example
#   class { 'icingaweb2::module::director':
#     git_revision  => 'v1.7.2',
#     db_host       => 'localhost',
#     db_name       => 'director',
#     db_username   => 'director',
#     db_password   => 'supersecret',
#     import_schema => true,
#     kickstart     => true,
#     endpoint      => 'puppet-icingaweb2.localdomain',
#     api_username  => 'director',
#     api_password  => 'supersecret',
#     require       => Mysql::Db['director']
#   }
#
class icingaweb2::module::director (
  Enum['mysql', 'pgsql']         $db_type,
  Enum['absent', 'present']      $ensure           = 'present',
  Enum['git', 'package', 'none'] $install_method   = 'git',
  Optional[String[1]]            $package_name     = undef,
  Stdlib::HTTPUrl                $git_repository   = 'https://github.com/Icinga/icingaweb2-module-director.git',
  Optional[String[1]]            $git_revision     = undef,
  Boolean                        $manage_service   = true,
  Stdlib::Ensure::Service        $service_ensure   = 'running',
  Boolean                        $service_enable   = true,
  String[1]                      $service_user     = 'icingadirector',
  Stdlib::Host                   $api_host         = 'localhost',
  Stdlib::Port                   $api_port         = 5665,
  Boolean                        $kickstart        = false,
  String[1]                      $db_resource_name = 'director',
  Stdlib::Host                   $db_host          = 'localhost',
  String[1]                      $db_name          = 'director',
  String[1]                      $db_username      = 'director',
  Optional[Stdlib::Port]         $db_port          = undef,
  Optional[String[1]]            $db_charset       = undef,
  Optional[Icinga::Secret]       $db_password      = undef,
  Optional[Boolean]              $import_schema    = undef,
  Stdlib::Absolutepath           $module_dir       = "${icingaweb2::globals::default_module_path}/director",
  Optional[Boolean]              $use_tls          = undef,
  Optional[Stdlib::Absolutepath] $tls_key_file     = undef,
  Optional[Stdlib::Absolutepath] $tls_cert_file    = undef,
  Optional[Stdlib::Absolutepath] $tls_cacert_file  = undef,
  Optional[Stdlib::Absolutepath] $tls_capath       = undef,
  Optional[Icinga::Secret]       $tls_key          = undef,
  Optional[String[1]]            $tls_cert         = undef,
  Optional[String[1]]            $tls_cacert       = undef,
  Optional[Boolean]              $tls_noverify     = undef,
  Optional[String[1]]            $tls_cipher       = undef,
  Optional[String[1]]            $endpoint         = undef,
  Optional[String[1]]            $api_username     = undef,
  Optional[Icinga::Secret]       $api_password     = undef,
) {
  require icingaweb2

  $module_conf_dir = "${icingaweb2::globals::conf_dir}/modules/director"
  $cert_dir        = "${icingaweb2::globals::state_dir}/director/certs"

  $db = {
    type     => $db_type,
    database => $db_name,
    host     => $db_host,
    port     => $db_port,
    username => $db_username,
    password => $db_password,
  }

  $tls = icinga::cert::files(
    $db_username,
    $cert_dir,
    $tls_key_file,
    $tls_cert_file,
    $tls_cacert_file,
    $tls_key,
    $tls_cert,
    $tls_cacert,
  )

  $db_settings = {
    'module-director-db' => {
      'section_name' => 'db',
      'target'       => "${module_conf_dir}/config.ini",
      'settings'     => {
        'resource'   => $db_resource_name,
      },
    },
  }

  if $kickstart {
    $kickstart_settings = {
      'module-director-config' => {
        'section_name' => 'config',
        'target'       => "${module_conf_dir}/kickstart.ini",
        'settings'     => {
          'endpoint'   => $endpoint,
          'host'       => $api_host,
          'port'       => $api_port,
          'username'   => $api_username,
          'password'   => unwrap($api_password),
        },
      },
    }
  } else {
    $kickstart_settings = {}
  }

  class { 'icingaweb2::module::director::install': }
  -> class { 'icingaweb2::module::director::config': }
  -> class { 'icingaweb2::module::director::kickstart': }
  -> class { 'icingaweb2::module::director::service':
    subscribe => Class['icingaweb2::module::director::config'],
  }
  contain icingaweb2::module::director::install
  contain icingaweb2::module::director::config
  contain icingaweb2::module::director::service
  contain icingaweb2::module::director::kickstart
}
