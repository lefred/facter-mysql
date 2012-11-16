# mysql.rb
# Facts related to MySQL status
#
# Author: Frederic -lefred- Descamps
# <lefred.descamps@gmail.com>
# http://www.lefred.be/
# license: GPLv2

# this code is hosted on github : https://github.com/lefred/facter-mysql

# this file should be installed in your facter directory, for example on a fedora 14 it is
# in /usr/lib/ruby/site_ruby/1.8/facter

mysql_path = '/usr/bin/mysql'

if File.exists?(mysql_path)

  # mysql command line to execute queries
  mysqlcmd = "#{mysql_path} -B -N -e"
  #status = %x[#{mysqlcmd} "SHOW STATUS"].to_s.strip
  status = %x[#{mysqlcmd} "SHOW STATUS"].split("\n")
  replica = %x[#{mysqlcmd} "SHOW SLAVE STATUS\\G"].split("\n")


  Facter.add(:mysql_version) do
    setcode do
      isinstalled = false
      os = Facter.value('operatingsystem')
      case os
        when "RedHat", "CentOS", "SuSE", "Fedora"
          [ 'mysql-server', 'MySQL-server-percona', 'Percona-Server-server' ].each { |dbtype|
            if isinstalled then next
            isinstalled = system "rpm -qa #{dbtype}\* >/dev/null 2>&1"
            end
          }
        when "Debian", "Ubuntu"
          ['mysql-server', 'Percona-server'].each { |dbtype|
            if isinstalled then next
            isinstalled = system "dpkg -l #{dbtype} 2>&1 | egrep '(^ii|^hi)' >/dev/null"
            end
          }
        else
      end
      if isinstalled then
        %x[#{mysqlcmd} "SELECT VERSION()"].to_s.strip
      end
    end
  end

  mysqlversion = Facter.value('mysql_version')

  if mysqlversion then
    Facter.add(:mysql_version_server) do
        setcode do
            %x[#{mysqlcmd} "SELECT @@VERSION_COMMENT"].to_s.strip
        end
    end
    status.each do|n|
      el=n.split("\t")
      Facter.add("mysql_#{el[0]}") do
        setcode do
            el[1]
        end
      end
    end
    replica.each do|n|
      el=n.split(":")
      Facter.add("mysql_replica_#{el[0].to_s.strip}") do
        setcode do
            el[1]
        end
      end
    end
  end
end