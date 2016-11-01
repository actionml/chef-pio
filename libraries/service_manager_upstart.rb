module PIO
  class ServiceManagerUpstart < ServiceBase
    resource_name :service_manager_upstart

    provides :_service_manager, platform: 'ubuntu'

    action :start do
      template "/etc/init/#{service_name}.conf" do
        path "/etc/init/#{service_name}.conf"
        source "services/upstart/#{service_name}.conf.erb"
        owner 'root'
        group 'root'
        mode '0644'
        variables provided_service_variables
        cookbook 'pio'

        notifies restart_action, new_resource, :immediately
        action :create
      end

      # start systemd service
      service service_name do
        provider Chef::Provider::Service::Upstart
        supports new_resource.supports
        action [:enable, :start]
      end
    end

    action :stop do
      service service_name do
        provider Chef::Provider::Service::Upstart
        supports new_resource.supports
        action [:disable, :stop]
        only_if { ::File.exist?("/etc/init/#{service_name}.conf") }
      end
    end

    action :restart do
      service service_name do
        provider Chef::Provider::Service::Upstart
        supports new_resource.supports
        action :restart
        only_if { ::File.exist?("/etc/init/#{service_name}.conf") }
      end
    end

    action :reload do
      service service_name do
        provider Chef::Provider::Service::Upstart
        supports new_resource.supports
        action :reload
        only_if { ::File.exist?("/etc/init/#{service_name}.conf") }
      end
    end
  end
end
