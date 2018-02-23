module PIOCookbook
  module HelpersMixin
    ## Auto defined PIO home (can be symlinked in the FS)
    #
    def pio_home
      @pio_home ||= if node['pio']['home'].to_s.empty?
                      "/home/#{node['pio']['user']}"
                    else
                      node['pio']['home']
                    end
    end

    ## PIO home directory (this is really represented in FS)
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

    ## Some default template variables
    #
    def default_variables
      {
        localdir:  node['pio']['localdir'],
        nofile:    node['pio']['ulimit_nofile'],
        java_home: (node['java'] and node['java']['java_home']),
        hadoopdir: ::File.join(node['pio']['localdir'], 'hadoop'),
        pio_home: pio_home
      }
    end

    ## Some variables for apache service templates
    #
    def apache_vars(**args)
      args[:appdir] = ::File.join(default_variables[:localdir], args[:app])
      default_variables.merge(args).compact
    end
  end
end
