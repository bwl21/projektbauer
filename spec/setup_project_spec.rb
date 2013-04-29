
$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'projektbauer.rb'

describe "it generates a svn + trac environemnt" do

  before :all do
    @p=Project.new
    @p.project_name = "project_01"
    @p.project_users = {
      admin: ["admin.first", "admin.second"],
      observer: ["observer.first", "observer.second"],
      contributor: ["contributor.first", "contributor.second", "contributor.third"]
    }
    @p.virtual_host  = "domain_01"
    @p.project_realm   = "Feldbauer-environment"
    @p.server_root = "#{File.dirname(__FILE__)}/tmp_output"
    @p.virtual_host_ip = "01.02.03.04"
    @p.server_name = "feldbauer.anydomain.tld"
    @p.server_admin = "#{@p.project_users[:admin].first}@#{@p.server_name}"
    @p.server_port_nossl = 8080
    @p.server_port_ssl = 443

  end



  it "creates the first test project" do
    @p.project_name = "project_01"
    @p.virtual_host  = "domain_01"

    @p.create_all
    @p.create_all

    cmd="svn ls file://\"#{@p.server_root}/#{@p.virtual_host}/#{@p.project_name}/svn\""
    result=`#{cmd}`
    result.should=="branches/\ntags/\ntrunk/\n"
  end

  it "creates the second test project" do
    @p.project_name = "project_02"
    @p.virtual_host  = "domain_01"
    @p.create_all
    @p.create_all
  end

  it "creates a another project set" do
    @p.project_name = "project_01"
    @p.virtual_host  = "domain_02"
    @p.create_all
    @p.create_all
  end

  it "handles spaces in path" do
    @p.project_name = "space project 01"
    @p.virtual_host  = "space domain 02"
    @p.create_all
    @p.create_all
  end

  it "properly updates htdigest file" do
    @p.project_name = "project_01"
    @p.virtual_host  = "domain_01"
    @p.project_users = {
      admin: ["admin.first", "admin.othersecond"],
      observer: ["observer.first", "observer.second", "observer.third"],
      contributor: ["contributor.first", "contributor.second", "contributor.third"]
    }
    @p.create_all
    pending("todo: investigate the changes")
    @p.create_all
  end

end
