
require './lib/projektbauer.rb'

p=Project.new
p.project_name = "p1"
p.project_users = {
  admin: ["admin.first", "admin.othersecond"],
  observer: ["observer.first", "observer.second", "observer.third"],
  contributor: ["contributor.first", "contributor.second", "contributor.third"]
}
p.virtual_host  = "weichel21_dev"
p.project_realm   = "Weichel21-Entwicklungen"
p.server_root = "/home/weichel21_projekte"
p.virtual_host_ip = "89.107.186.40"
p.server_name = "svn.weichel21.de"
p.server_admin = "bernhard@weichel21.de"
p.server_port_nossl = 1337
p.server_port_ssl = 62877

p.trac_admin = "/home/bwl_virtualenv/bin/trac-admin"

##

p.create_all

p.project_name = "p2"

p.create_all  
