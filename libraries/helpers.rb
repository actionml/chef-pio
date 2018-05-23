module PIOCookbook
  module HelpersMixin
    ## Computed home this one should be used to identify where PIO
    #  user home is. Note that pio_home is not the directory where PIO is installed
    #  it's the PIO user directory!!!
    #
    def pio_home
      @pio_home ||= if node['pio']['home'].to_s.empty?
                      "/home/#{node['pio']['user']}"
                    else
                      node['pio']['home']
                    end
    end

    ## PIO user home directory (this directory will be really represented in FS)
    #  The default behavior is to place the home directory into the datadir,
    #  unless the value was provided by node['pio']['home'] attribute.
    #
    def pio_homedir
      @pio_homedir ||=
        begin
          if pio_home == node['pio']['home']
            # home is provided by user
            pio_home
          else
            # we place home in the datadir
            ::File.join(node['pio']['datadir'], "#{node['pio']['user']}-home")
          end
        end
    end

    def pio_srcdir
      @pio_srcdir ||= "#{node['pio']['localdir']}/src/pio"
    end

    # Method finds the pio dist version
    def _grep_pio_distver
      version = ::File.open("#{pio_srcdir}/build.sbt")
                      .readlines.select { |l| l =~ /^version in ThisBuild/ }
                      .pop.chomp

      # extract the real version name
      version.gsub!(/.*:=\s+"(.*)"/, '\1')
    rescue SystemCallError
      Chef::Log.error('method can be used ONLY after the build (make-distribution.sh)')
      raise
    end

    # PredictionIO version
    def pio_version
      @pio_version ||= case node['pio']['pio']['install_method']
                       when 'source'
                         _grep_pio_distver
                       when 'binary'
                         node['pio']['pio']['version']
                       end
    end

    # data directory (default: /opt/data)
    def datadir
      @datadir ||= node['pio']['datadir']
    end

    # apps directory (default: /usr/local)
    def localdir
      @localdir ||= node['pio']['localdir']
    end

    # Useful defaults defined for template generations.
    def default_variables
      @default_variables ||= {
        datadir:   datadir,
        localdir:  localdir,
        sparkdir:  "#{localdir}/spark",
        hadoopdir: "#{localdir}/hadoop",
        nofile:    node['pio']['ulimit_nofile'],
        java_home: (node['java'] and node['java']['java_home']),
        pio_home: pio_home
      }
    end

    # Apache vars: contains substituted appdir if app has been passed.
    def apache_vars(**args)
      args[:appdir] = ::File.join(localdir, args[:app])
      default_variables.merge(args).compact
    end

    def provision_only?
      node['pio']['provision_only']
    end

    def service_actions
      provision_only? ? [:enable] : [:enable, :start]
    end
  end
end
