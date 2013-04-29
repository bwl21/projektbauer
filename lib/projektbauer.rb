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
#
# projektbauer init
# projektbuaer updateuser
# projektbauer add user
# ...
#
#
require 'fileutils'
require 'erb'

class Project
  attr_accessor  :output_folder,    # output folder - currently not in use
    :server_name,                   # server name of the virtual host <apache>
    :server_root,                   # root folder on the server <apache>
    :server_admin,                  # name of the server administrator <apache>
    :document_root,                 # document root within the location <apache>
    :project_name,                  # name of the project (please no spaces) \
    # used for filename
    :project_users,                 # hash of project users. Key is :admin, :observer, :contributor
    :virtual_host,                  # domain of virtual host
    :project_realm,                 # realm for the project authentification
    :virtual_host_ip,               # ip of the virtual host without port
    :server_port_nossl,             # port for the no ssl access of the virtual host (e.g. 8080)
    :server_port_ssl                # port of ssel access to the virtual host (e.g. 443)




  #
  # The class constructor
  #
  # @return [Project] returns the created class
  def initialize

    @server_port_nossl = nil
    @server_port_ssl = nil
    @server_root = "xxx"


    @project_name        = nil  # name of project
    @virtual_host        = nil  # set of the project
    @project_realm       = nil  # realm for authorization
    @project_admin_user  = nil  # admin - user
    @server_admin        = nil  # email of server admin

  end


  #
  # Inititalizes filenames etc. Needs to be called
  # whenever one or more of the attributes are changed.
  #
  # @return [nil] no return
  def init_filenames

    #todo add checks for the attributes
    # no spaces in project_name
    #

    @_virtual_host_home_dir               = "#{@server_root}/#{@virtual_host}"
    @_include_virtual_hosts_httpd_conf    = "#{@server_root}/include_virtual_hosts.httpd.conf"
    @_project_home                        = "#{@_virtual_host_home_dir}/#{@project_name}"
    @_virtual_host_httpd_conf             = "#{@_virtual_host_home_dir}/virtual_host.httpd.conf"
    @_virtual_host_locations_httpd_conf   = "#{@_virtual_host_home_dir}/include_locations.httpd.conf"
    @_project_location_httpd_conf         = "#{@_project_home}/#{@project_name}.httpd.conf"
    @_project_svn_dir                     = "#{@_project_home}/svn"
    @_project_trac_dir                    = "#{@_project_home}/trac"
    @_project_auth_user_file              = "#{@_project_home}/#{@project_realm}.htdigest"
    @_project_svn_authz_file              = "#{@_project_home}/#{@project_name}.dav_svn_authz"
    @_document_root_dir                   = "#{@_virtual_host_home_dir}/www"
    @_index_html_file                     = "#{@_document_root_dir}/index.html"

    nil
  end



  #
  # Creates the folders in the file system.
  # If a folder already exists, nothing happens.
  #
  # @return [nil] no return
  #
  def create_folders
    #todo: double check if path exists
    FileUtils.mkdir_p @_project_svn_dir
    FileUtils.mkdir_p @_project_trac_dir
    FileUtils.mkdir_p @_document_root_dir
    #todo: ensure that folders are not listable
    #todo: htaccess - file
    nil
  end



  #
  # This basically creates the configuration of the virtual host
  #
  # @return [Nil] no return
  #
  def save_virtual_host_httpd_conf
    config = expand_erb("virtual_host_httpd_conf.erb")

    File.open(@_virtual_host_httpd_conf,"w"){|f|
      f.puts config
    }

    nil
  end


  #
  # create the apache configuration for the <location>
  # It corresponds to a project.
  #
  # @return [Nil] no return
  def save_project_location_httpd_conf
    config = expand_erb("project_location_httpd_conf.erb")

    File.open(@_project_location_httpd_conf,"w"){|f|
      f.puts config
    }

    nil
  end


  #
  # creates the Authorization file for svn.
  # Thereby it creates an observer and a contributor group.
  # the {Project.project_admin_user} is entered as contributor
  #
  # @return [Nil] no return
  def create_svn_authz_file
    config =expand_erb("svn_authz_file.erb")

    File.open(@_project_svn_authz_file, "w") {|f|
      f.puts config
    }
    nil
  end


  #
  # Creates a minimalistic index.html in the virtual host.
  # In particular this avoids that the files can be listed.
  #
  # @return [Nil] no return
  #
  def create_index_html
    config = expand_erb("index_html.erb")
    File.open(@_index_html_file, "w") {|f|
      f.puts config
    }
  end


  #
  # Updates the include file with the locations.
  # This file is subsequently included in the virtual hosts.
  #
  # Duplicate entries are removed.
  #
  # @return [Nil] no return
  def update_virtual_host_locations_httpd_conf
    _maintain_include_file(@_virtual_host_locations_httpd_conf,
                           @_project_location_httpd_conf
                           )
  end


  #
  # Updates the include file with the virtual hosts.
  # This file needs to be added manually to `/etc/apache2/apache2.conf`
  #
  # @return [Nil] no return
  def update_include_virtual_hosts_httpd_conf
    _maintain_include_file(@_include_virtual_hosts_httpd_conf,
                           @_project_location_httpd_conf
                           )
    nil
  end


  def create_trac
    cmd = "trac-admin #{@_project_trac_dir} initenv"
  end


  #
  # This creates the svn repository if it does not yet exist.
  # Note that this is tested by investigating the format
  # folder in the svn repository.
  #
  # todo: improve the detection
  #
  # @return [type] [description]
  def create_svn
    unless File.exists?(@_project_svn_dir + "/format")
      cmd = "svnadmin create \"#{@_project_svn_dir}\""
      puts cmd
      `#{cmd}`
      initialfolders= ["tags", "branches", "trunk"]
      cmd = ["svn mkdir",
            initialfolders.map{|d| "file://\"#{@_project_svn_dir}\"/#{d}"},
            "-m \"Repository created by Projektbauer\""].flatten.join(" ")
      puts cmd
      `#{cmd}`
    end
  end


  def connect_svn_trac

  end


  #
  # This creates the htdigest file
  #
  # @return [Nil] no return
  def create_htpasswd

    allusers = @project_users.map{|k,v| v}.flatten
    pwdhashes = {}
    passwords = {}
    allusers.each{|user|
      password = (0...10).map{ ('a'..'z').to_a[rand(26)] }.join
      pwdhashes[user] = _create_passwdentry(@project_realm, user, password)
      passwords[user] = password
    }

    if File.exists?(@_project_auth_user_file) then
      oldcontents = File.open(@_project_auth_user_file).readlines
      oldcontents = oldcontents.map{|i| i.strip }.sort.uniq

      oldentries={}
      oldcontents.each{|entry|
 
        record = entry.split(":")
        if pwdhashes.has_key?(record.first) then
          pwdhashes[record.first] = entry
          passwords[record.first] = "<password unchanged>"
        else
          passwords[record.first] = "<user deleted>"
        end
      }
    else
      oldcontents=[]
    end

    newcontents=pwdhashes.map{|k,v| v }.sort.uniq
    unless oldcontents==newcontents
      File.open(@_project_auth_user_file, "w"){|f|
        f.puts(newcontents.join("\n"))
      }
    end

    File.open(@_project_auth_user_file+".txt", "w"){|f|
      f.puts "generated passwords for #{@project_realm}"
      f.puts ""
      f.puts(passwords.map{|k,v| "#{k} => #{v}"}.sort.join("\n"))
    }

  end



  #
  # calling this method after setting all attributes
  # does the entire generation job
  #
  # @return [Nil] no return
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


  #
  # This expands the embedded ruby templated
  # @param  file [String] Path to the erb template
  #
  # @return [String] Expanded Templated
  def expand_erb(file)
    template=ERB.new File.new(File.dirname(__FILE__)+ "/projektbauer/erb/" + file).readlines.join
    template.result(binding)
  end


  #
  # This maintains an include file as follows:
  #
  # - the file is read
  # - the new entry is appended
  # - the result is sorted an duplicates are removed
  # - the file is saved if it is different than before
  #
  # @param  include_file [String] Name if the include file to be maintained
  # @param  entry [String] The new entry which shall be included
  #
  # @return [Nil] no return
  #
  def _maintain_include_file(include_file, entry)
    if File.exists?(include_file) then
      old = File.open(include_file).readlines.map{|i| i.strip}
      new=old.clone
    else
      new=[]
    end

    new << "Include #{entry}"

    new=new.sort.uniq

    unless old == new then
      File.open(include_file, "w") {|f|
        f.puts new.join("\n")
      }
    end
    nil
  end

  def _create_post_commit(file)
  end

  def _update_trac_ini(file)
  end

  def _create_passwdentry(realm, user, password)
    pwdcmd=%Q[(printf '#{user}:#{realm}:#{password}') | md5]
    pwdhash=`#{pwdcmd}`.strip
    result="#{user}:#{realm}:#{pwdhash}"
    result
  end


  def _set_trac_permissions

    ## assigning permissions

    #see <http://trac.edgewall.org/wiki/TracPermissions>

    #/trac-admin bwl_trac/ permission add <user> TRAC_ADMIN

    #**note**: Ensure the appropriate permissions in admin, in particular be careful about the rights of "anonymous"

  end

end
