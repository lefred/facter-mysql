# mysql.rb
# Facts related to MySQL status
#
# Frederic -lefred- Descamps
# <lefred.descamps@gmail.com>
# http://www.lefred.be/

# this code is hosted on github :

# this file should be installed in your facter directory, for example on a fedora 14 it is
# in /usr/lib/ruby/site_ruby/1.8/facter
 
# mysql command line to execute queries
mysqlcmd = 'mysql -B -N -e'
#status = %x[#{mysqlcmd} "SHOW STATUS"].to_s.strip
status = %x[#{mysqlcmd} "SHOW STATUS"].split("\n")

Facter.add(:mysql_version) do
  setcode do
    isinstalled = false
    os = Facter.value('operatingsystem')
    case os
      when "RedHat", "CentOS", "SuSE", "Fedora"
        isinstalled = system "rpm -q mysql-server >/dev/null 2>&1"
        if not isinstalled then
            isinstalled = system "rpm -q Percona-server >/dev/null 2>&1"
        end
      when "Debian", "Ubuntu"
        isinstalled = system "dpkg -l mysql-server 2>&1 | egrep '(^ii|^hi)' >/dev/null"
        if not isinstalled then
            isinstalled = system "dpkg -l Percona-server 2>&1 | egrep '(^ii|^hi)' >/dev/null"
        end
      else
    end
    if isinstalled then
      %x[#{mysqlcmd} "SELECT VERSION()"].to_s.strip
    end
  end
end

mysqlversion = Facter.value('mysql_version')

if mysqlversion then
    status.each do|n|
      el=n.split("\t")
      Facter.add("mysql_#{el[0]}") do
        setcode do
            el[1]
        end
      end
    end
end
