#see BernhardsDokumentation.md
#
# todo:
#
# add comments
# optimize file layout
# improve auth handling
#   store auth-files in folder of virtual server
#   cross use auth-files
#   update htdigest files
#   add rake tasks
#     * add user
#     * specifiy observer, contributors on config file
#     * update trac permissions accordingly
# use erb for templates
# make a gem out of it:
#
# projektbauer init
# projektbuaer updateuser
# projektbauer add user
# ...
#

# mod_dav_fs
#
#

require 'fileutils'
require 'erb'

class Project
  attr_accessor  :output_folder,
    :server_name,
    :server_root,
    :server_admin,
    :document_root,
    :project_name,
    :project_admin_user,
    :virtual_host,
    :project_realm,
    :virtual_host_ip,
    :virtual_host_domain,
    :server_port_nossl,
    :server_port_ssl




  def initialize

    @virtual_host_domain = nil
    @server_port_nossl = nil
    @server_port_ssl = nil
    @server_root = "xxx"


    @project_name        = nil  # name of project
    @virtual_host         = nil  # set of the project
    @project_realm       = nil  # realm for authorization
    @project_admin_user  = nil  # admin - user
    @server_admin        = nil  # email of server admin

  end

  def init_filenames
    @_virtual_host_home                   = "#{@server_root}/#{@virtual_host}"
    @_include_virtual_hosts_httpd_conf    = "#{@server_root}/include_virtual_hosts.httpd.conf"
    @_project_home                        = "#{@_virtual_host_home}/#{@project_name}"
    @_virtual_host_httpd_conf             = "#{@_virtual_host_home}/virtual_host.httpd.conf"
    @_virtual_host_locations_httpd_conf   = "#{@_virtual_host_home}/include_locations.httpd.conf"
    @_project_location_httpd_conf         = "#{@_project_home}/#{@project_name}.httpd.conf"
    @_project_svn_dir                     = "#{@_project_home}/svn"
    @_project_trac_dir                    = "#{@_project_home}/trac"
    @_project_auth_user_file              = "#{@_project_home}/#{@project_realm}.htdigest"
    @_project_svn_authz_file              = "#{@_project_home}/#{@project_name}.dav_svn_authz"
    @_document_root_dir                   = "#{@_virtual_host_home}/www"
    @_index_html_file                     = "#{@_document_root_dir}/index.html"
  end

  def create_folders
    #todo: double check if path exists
    FileUtils.mkdir_p @_project_svn_dir
    FileUtils.mkdir_p @_project_trac_dir
    FileUtils.mkdir_p @_document_root_dir
    #todo: crate index.html
    #todo: ensure that folders are not listable
    #todo: htaccess - file
  end


  def save_virtual_host_httpd_conf
    config = expand_erb("virtual_host_httpd_conf.erb")

    File.open(@_virtual_host_httpd_conf,"w"){|f|
      f.puts config
    }
  end

  # create the entry for the apache configuration
  def save_project_location_httpd_conf

    config = expand_erb("project_location_httpd_conf.erb")

    File.open(@_project_location_httpd_conf,"w"){|f|
      f.puts config
    }

  end

  def create_svn_authz_file

    #todo remove indentation
    config =expand_erb("svn_authz_file.erb")

    File.open(@_project_svn_authz_file, "w") {|f|
      f.puts config
    }

  end


  def create_index_html
    config = expand_erb("index_html.erb")
    File.open(@_index_html_file, "w") {|f|
      f.puts config
    }
  end


  def update_virtual_host_locations_httpd_conf

    if File.exists?(@_virtual_host_locations_httpd_conf) then
      old = File.open(@_virtual_host_locations_httpd_conf).readlines.map{|i| i.strip}
      new=old.clone
    else
      new=[]
    end

    new << "Include #{@_project_location_httpd_conf}"

    new=new.sort.uniq

    unless old == new then
      File.open(@_virtual_host_locations_httpd_conf, "w") {|f|
        f.puts new.join("\n")
      }
    end
  end

  def update_include_virtual_hosts_httpd_conf
    if File.exists?(@_include_virtual_hosts_httpd_conf) then
      old = File.open(@_include_virtual_hosts_httpd_conf).readlines.map{|i| i.strip}
      new=old.clone
    else
      new=[]
    end

    new << "Include #{@_project_location_httpd_conf}"

    unless old == new then
      File.open(@_include_virtual_hosts_httpd_conf, "w") {|f|
        f.puts new.join("\n")
      }
    end
  end

  def create_trac
    config <<-eos
    # system trac-admin "#{@virtual_host}/#{@project_name}/trac initenv"
    # fix permissions
    eos
  end

  def create_svn
    unless File.exists?(@_project_svn_dir + "/format")
      cmd = "svnadmin create \"#{@_project_svn_dir}\""
      puts cmd
      `#{cmd}`
    end
  end


  def connect_svn_trac

  end

  def create_htpasswd
    unless File.exists?(@_project_auth_user_file) then
      cmd = "htdigest -c \"#{@_project_auth_user_file}\"  \"#{@project_realm}\" #{@project_admin_user}"
      puts cmd
      `#{cmd}`
    else
      #todo: update htpasswd
    end
  end

  def create_all
    init_filenames
    create_folders

    create_index_html

    save_virtual_host_httpd_conf
    save_project_location_httpd_conf
    update_virtual_host_locations_httpd_conf
    update_include_virtual_hosts_httpd_conf

    create_htpasswd
    create_svn_authz_file
    create_svn
  end


  private

  def expand_erb(file)
    template=ERB.new File.new(File.dirname(__FILE__)+ "/projektbauer/erb/" + file).readlines.join
    template.result(binding)
  end



  def _create_post_commit(file)
  end

  def _update_trac_ini(file)
  end


  def _set_trac_permissions

    ## assigning permissions

    #see <http://trac.edgewall.org/wiki/TracPermissions>

    #/trac-admin bwl_trac/ permission add <user> TRAC_ADMIN

    #**note**: Ensure the appropriate permissions in admin, in particular be careful about the rights of "anonymous"

  end

end
