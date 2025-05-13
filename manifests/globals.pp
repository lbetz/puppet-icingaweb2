# @summary
#   This class loads the default parameters by doing a hiera lookup.
#
# @note This parameters depend on the os plattform. Changes maybe will break the functional capability of the supported plattforms and versions. Please only do changes when you know what you're doing.
#
# @param package_name
#   Package to install.
#
# @param conf_dir
#   Path to the config files.
#
# @param state_dir
#   Path to variable application data.
#
# @param data_dir
#   Location of PHP data files.
#
# @param role_replace
#   Specifies whether to overwrite the roles.ini file if it already exists.
#
# @param comp_db_schema_dir
#   For compatibility, since in Icinga Web 2 2.11.4 the schema files have been moved.
#
# @param default_module_path
#   Location of the modules.
#
# @param mysql_db_schema
#   Location of the database schema for MySQL/MariaDB.
#
# @param pgsql_db_schema
#   Location of the database schema for PostgreSQL.
#
# @param mysql_vspheredb_schema
#   Location of the vspheredb database schema for MySQL/MariaDB.
#
# @param pgsql_vspheredb_schema
#   Location of the vspheredb database schema for PostgreSQL.
#
# @param mysql_reporting_schema
#   Location of the reporting database schema for MySQL/MariaDB.
#
# @param pgsql_reporting_schema
#   Location of the reporting database schema for PostgreSQL.
#
# @param mysql_idoreports_slaperiods
#   Location of the slaperiods database extension for MySQL.
#
# @param mysql_idoreports_sla_percent
#   Location of the get_sla_ok_percent database extension for MySQL.
#
# @param pgsql_idoreports_slaperiods
#   Location of the slaperiods database extension for PostgreSQL.
#
# @param pgsql_idoreports_sla_percent
#   Location of the get_sla_ok_percent database extension for PostgreSQL.
#
# @param mysql_x509_schema
#   Location of the x509 database schema for MySQL/MariaDB.
#
# @param pgsql_x509_schema
#   Location of the x509 database schema for PostgreSQL.
#
# @param gettext_package_name
#   Package name `gettext` tool belongs to.
#
# @param icingacli_bin
#   Path to `icingacli' comand line tool.
#
class icingaweb2::globals (
  String[1]              $package_name,
  String[1]              $gettext_package_name,
  Stdlib::Absolutepath   $conf_dir,
  Stdlib::Absolutepath   $state_dir,
  Stdlib::Absolutepath   $data_dir,
  Stdlib::Absolutepath   $icingacli_bin,
  Stdlib::Absolutepath   $comp_db_schema_dir,
  Stdlib::Absolutepath   $default_module_path,
  Stdlib::Absolutepath   $mysql_db_schema,
  Stdlib::Absolutepath   $pgsql_db_schema,
  Stdlib::Absolutepath   $mysql_vspheredb_schema       = '/schema/mysql.sql',
  Stdlib::Absolutepath   $pgsql_vspheredb_schema       = '/schema/pgsql.sql',
  Stdlib::Absolutepath   $mysql_reporting_schema       = '/schema/mysql.schema.sql',
  Stdlib::Absolutepath   $pgsql_reporting_schema       = '/schema/pgsql.schema.sql',
  Stdlib::Absolutepath   $mysql_idoreports_slaperiods  = '/schema/mysql/slaperiods.sql',
  Stdlib::Absolutepath   $mysql_idoreports_sla_percent = '/schema/mysql/get_sla_ok_percent.sql',
  Stdlib::Absolutepath   $pgsql_idoreports_slaperiods  = '/schema/postgresql/slaperiods.sql',
  Stdlib::Absolutepath   $pgsql_idoreports_sla_percent = '/schema/postgresql/get_sla_ok_percent.sql',
  Stdlib::Absolutepath   $mysql_x509_schema            = '/schema/mysql.schema.sql',
  Stdlib::Absolutepath   $pgsql_x509_schema            = '/schema/pgsql.schema.sql',
  Boolean                $role_replace                 = true,
) {
  $stdlib_version = load_module_metadata('stdlib')['version']

  $db_charset = {
    'mysql' => {
      'director'  => 'utf8',
      'vspheredb' => 'utf8mb4',
      'reporting' => 'utf8mb4',
      'x509' => 'utf8',
    },
    'pgsql' => {
      'director' => 'UTF8',
      'vspheredb' => 'UTF8',
      'reporting' => 'UTF8',
      'x509' => 'UTF8',
    },
  }

  # deprecated
  $port = {
    'mysql' => 3306,
    'pgsql' => 5432,
  }
}
