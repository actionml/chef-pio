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

    declare_action_class.class_eval do
      def write_init_files
        template "/etc/systemd/system/#{service_name}.service" do
          path "/etc/systemd/system/#{service_name}.service"
          source "services/systemd/#{service_name}.service.erb"
          owner 'root'
          group 'root'
          mode '0644'
          variables provided_service_variables
          cookbook 'pio'

          action :create
        end

        # avoid 'Unit file changed on disk' warning
        execute "#{service_name} systemctl daemon-reload" do
          command '/bin/systemctl daemon-reload'
          subscribes :run, "template[/etc/systemd/system/#{service_name}.service]", :immediately
          action :nothing
        end
      end
    end


    action :start do
      # create init files resources
      write_init_files

      # start systemd service
      service service_name do
        provider Chef::Provider::Service::Systemd
        supports new_resource.supports

        unless provision_only?
          subscribes reload_action, "template[/etc/systemd/system/#{service_name}.service]", :immediately
        end

        action [:enable, provision_only? ? :nothing : :start]
      end
    end

    action :stop do
      service service_name do
        provider Chef::Provider::Service::Systemd
        supports new_resource.supports
        only_if { ::File.exist?("/etc/systemd/system/#{service_name}.service") }

        action [:disable, :stop]
      end
    end

    action :restart do
      # create init files resources
      write_init_files

      service service_name do
        provider Chef::Provider::Service::Systemd
        supports new_resource.supports

        unless provision_only?
          subscribes :restart, "template[/etc/systemd/system/#{service_name}.service]", :immediately
        end

        action provision_only? ? :nothing : :restart
      end
    end

    action :reload do
      # create init files resources
      write_init_files

      service service_name do
        provider Chef::Provider::Service::Systemd
        supports new_resource.supports

        unless provision_only?
          subscribes reload_action, "template[/etc/systemd/system/#{service_name}.service]", :immediately
        end

        action provision_only? ? :nothing : reload_action
      end
    end

  end
end
