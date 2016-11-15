module PIO
  class ServiceManagerUpstart < ServiceBase
    resource_name :service_manager_upstart

    provides :_service_manager, platform: 'ubuntu'

    declare_action_class.class_eval do
      def write_init_files
        template "/etc/init/#{service_name}.conf" do
          path "/etc/init/#{service_name}.conf"
          source "services/upstart/#{service_name}.conf.erb"
          owner 'root'
          group 'root'
          mode '0644'
          variables provided_service_variables
          cookbook 'pio'

          action :create
        end
      end
    end

    action :start do
      # create init files resources
      write_init_files

      # start systemd service
      service service_name do
        provider Chef::Provider::Service::Upstart
        supports new_resource.supports

        unless provision_only?
          subscribes reload_action, "template[/etc/init/#{service_name}.conf]", :immediately
        end

        action [:enable, provision_only? ? :nothing : :start]
      end
    end

    action :stop do
      service service_name do
        provider Chef::Provider::Service::Upstart
        supports new_resource.supports
        only_if { ::File.exist?("/etc/init/#{service_name}.conf") }

        action [:disable, :stop]
      end
    end

    action :restart do
      # create init files resources
      write_init_files

      service service_name do
        provider Chef::Provider::Service::Upstart
        supports new_resource.supports

        unless provision_only?
          subscribes :restart, "template[/etc/init/#{service_name}.conf]", :immediately
        end

        action provision_only? ? :nothing : :restart
      end
    end

    action :reload do
      # create init files resources
      write_init_files

      service service_name do
        provider Chef::Provider::Service::Upstart
        supports new_resource.supports

        unless provision_only?
          subscribes reload_action, "template[/etc/init/#{service_name}.conf]", :immediately
        end

        action provision_only? ? :nothing : reload_action
      end
    end

  end
end
