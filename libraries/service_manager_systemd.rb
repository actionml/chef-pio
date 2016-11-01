module PIO
  class ServiceManagerSystemd < ServiceBase
    resource_name :service_manager_systemd

    provides :_service_manager, platform: 'fedora'

    provides :_service_manager, platform: %w(redhat centos) do |node|
      node['platform_version'].to_f >= 7.0
    end

    provides :_service_manager, platform: 'debian' do |node|
      node['platform_version'].to_f >= 8.0
    end

    provides :_service_manager, platform: 'ubuntu' do |node|
      node['platform_version'].to_f >= 15.04
    end

    action :start do
      template "/etc/systemd/system/#{service_name}.service" do
        path "/etc/systemd/system/#{service_name}.service"
        source "services/systemd/#{service_name}.service.erb"
        owner 'root'
        group 'root'
        mode '0644'
        variables provided_service_variables
        cookbook 'pio'

        notifies :run, "execute[#{service_name} systemctl daemon-reload]", :immediately
        notifies restart_action, new_resource, :immediately
        action :create
      end

      # avoid 'Unit file changed on disk' warning
      execute "#{service_name} systemctl daemon-reload" do
        command '/bin/systemctl daemon-reload'
        action :nothing
      end

      # start systemd service
      service service_name do
        provider Chef::Provider::Service::Systemd
        supports new_resource.supports
        action [:enable, :start]
      end
    end

    action :stop do
      service service_name do
        provider Chef::Provider::Service::Systemd
        supports new_resource.supports
        action [:disable, :stop]
        only_if { ::File.exist?("/etc/systemd/system/#{service_name}.service") }
      end
    end

    action :restart do
      service service_name do
        provider Chef::Provider::Service::Systemd
        supports new_resource.supports
        action :restart
        only_if { ::File.exist?("/etc/systemd/system/#{service_name}.service") }
      end
    end

    action :reload do
      service service_name do
        provider Chef::Provider::Service::Systemd
        supports new_resource.supports
        action :reload
        only_if { ::File.exist?("/etc/systemd/system/#{service_name}.service") }
      end
    end
  end
end
