package :postgre_apt do
  apt_list    = '/etc/apt/sources.list.d/pgdg.list'
  apt_source  = "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main\n"

  push_text apt_source, apt_list, sudo: true do
    pre :install, 'true && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -'
    post :install, 'sudo apt-get update'
  end

  verify do
    file_contains apt_list, 'precise-pgdg'
  end
end

# This can be usefull if you do not need server itself but want to connect to remote server
package :postgresql_client do
  requires :postgre_apt
  # apt 'pqdev'
  apt 'postgresql-client-9.3'

  verify do
    has_apt 'postgresql-client-9.3'
  end
end

package :postgresql_server do
  requires :postgre_apt
  apt 'postgresql-9.3 postgresql-contrib-9.3'

  verify do
    has_apt "postgresql-9.3"
    has_apt "postgresql-contrib-9.3"
  end
end

package :postgres_configured do
  requires :postgresql_server, :update_pg_hba
end

package :update_pg_hba do
  description 'PostgreSQL: Config'

  config_file_path = '/etc/postgresql/9.3/main/pg_hba.conf'
  config_template = File.join(File.dirname(__FILE__), 'configs', 'pg_hba.conf')

  file config_file_path, contents: File.read(config_template), sudo: true

  runner "chown postgres:postgres #{config_file_path}"
  runner "chmod 755 #{config_file_path}"
  runner 'service postgresql restart'

  verify do
    has_file config_file_path
    has_permission config_file_path, '755'
    belongs_to_user config_file_path, 'postgres'
    belongs_to_group config_file_path, 'postgres'
  end
end

#TODO:
# auto restart after reboot, https://github.com/grimen/sprinkle-stack/blob/master/packages/database/postgresql.rb
