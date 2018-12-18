# this project is no longer maintained

As we all now use git, containers and all that stuff, this project is no longer maintained.

# Projektbauer

Projektbauer (a german play on words which could be translated to
"project builder" or to "poject farmer") is a ruby gem which supports
the setup of an SVN/Trac environment in an apache enviroment.

To use it one creates a configuration file which is actually a ruby
script and executes the same. The following approach applies

-   **top level project folder** all projects are kept under one
    particular folder for a **project collection** Usually on one host,
    there is exactly one project collection.

-   **virtual host** acting as project set: Within the project
    collection, multiple project sets can be installed. One project set
    corelates to an apache virtual host (e.g `myprojects.mydomin.xx`).
    **Projektbauer** creates an apache configuration file for this
    virtual domain.

    **Projektbauer** supports virtual host by
    -   creating a folder for the virtual host
    -   creating an apache configuration for that virtual host
        (`virtual_host.httpd.conf`)
    -   maintains a configuration file (`include_locations.httpd.conf`)
        which is be included in the aforehead mentioned file. This file
        includes the project configurations.

    **Note** that some providers (e.g. <http://www.webhostone.de>) do
    not support creation of virtual hosts this way. In this case, you
    can simply ignore the generated virtual host. But you need to
    include the project list in the existing virtual host.

-   **project** a project is associated with a **virtual host** such
    that it can be accessed by
    -   `https://myprojects.mydomin.xx/myproject/svn`
    -   `https://myprojects.mydomin.xx/myproject/trac`

    **Projektbauer** generates the configuration of the the project,
    namely:
    -   svn repository
    -   htdigest user file
    -   svn_authz file

## Installation

As of now **Projektbauer** is not released at <http://rubygems.org>. Therefore you need 
to install it on your server by

	$ git clone https://github.com/bwl21/projektbauer.git

Add this line to your application's Gemfile:

    gem 'projektbauer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install projektbauer

## Usage

In order to use **Projektbauer** you need to create a configuration file 
which is in fact a ruby program.

	require './lib/projektbauer.rb'

	p=Project.new
	p.project_name = "{name of the project}"
    p.project_users = {
      admin: ["admin.first", "admin.second"],
      observer: ["observer.first", "observer.second"],
      contributor: ["contributor.first", "contributor.second"]
    }
	p.virtual_host  = "{server internal folder name of the virtual host,}"
	p.project_realm   = "{realm for authorization, no spaces, no colons!}"
	p.server_root = "{path to top level project folder on the server}"
	p.virtual_host_ip = "{url of virtual host without port}"
	p.server_name = "{domain of the virtual host}"
	p.server_admin = "{email adress}"
	p.server_port_nossl = 8080
	p.server_port_ssl = 443

    # this is required for the trac configuration

    p.smtp_default_domain = "foo.bar.de"              # Default dopmain for smtp
    p.smtp_enabled = true                             # allow trac to send smtp
    p.smtp_from = "projektbauer@foo.bar.de"           # sender adress
    p.smtp_from_author = false                        # not supported defaults to false
    p.smtp_from_name = "Projekt bauer at foo bar de"  # name of sender adress
    p.smtp_user = "sample.user.smtp"                  # username for smtp
    p.smtp_password = "sample.password.smtp"          # password for smtp
    p.smtp_port = 25                                  # port for smtp 
    p.smtp_replyto = "projetkbauer.trac.replyto@#{@p.server_name}" # reply-to adress
    p.smtp_server = @p.server_name                    # smtp-server
    p.smtp_subject_prefix = "__default__"             # prefix for subject = __default__


	p.create_all

For more details refer to the yard documentation included.

Note that you can run it repeatedly. Thereby

-   new users are created
-   old users are removed

you can see this in the project folder, in file `{project_realm}.htdigest.txt`

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request
