
$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'projektbauer.rb'

describe "it generates a svn + trac environemnt" do

  before :all do
    @p=Project.new
    @p.project_name = "project_01"
    @p.virtual_host  = "domain_01"
    @p.project_admin_user = "feld.bauer"
    @p.project_realm   = "Feldbauer-environment"
    @p.server_root = "#{File.dirname(__FILE__)}/tmp_output"
    @p.virtual_host_ip = "01.02.03.04"
    @p.server_name = "feldbauer.anydomain.tld"
    @p.server_admin = "#{@p.project_admin_user}@#{@p.server_name}"
    @p.server_port_nossl = 8080
    @p.server_port_ssl = 443
  end



  it "creates the first test project" do
    @p.project_name = "project_01"
    @p.virtual_host  = "domain_01"

    @p.create_all
  end

  it "creates the second test project" do
    @p.project_name = "project_02"
    @p.virtual_host  = "domain_01"
    @p.create_all
  end

  it "creates a another project set" do
    @p.project_name = "project_01"
    @p.virtual_host  = "domain_02"
    @p.create_all
  end

  it "handles spaces in path" do
    @p.project_name = "space project 01"
    @p.virtual_host  = "space domain 02"
    @p.create_all
  end

end

