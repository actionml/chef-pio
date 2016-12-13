module PIO
  require_relative 'service_base'


  class ServiceManager < ServiceBase
    resource_name :service_manager
    provides :service_manager

    property :manager, %w(execute upstart systemd auto), default: 'auto', desired_state: false
    property :exec_command, [String, Symbol]
    property :exec_logfile, String
    property :exec_procregex, String
    property :exec_cwd, String
    property :exec_env, Hash

    def copy_properties_to(to, *properties)
      properties = self.class.properties.keys if properties.empty?
      properties.each do |p|
        # If the property is set on from, and exists on to, set the
        # property on to
        if to.class.properties.include?(p) && property_is_set?(p)
          to.send(p, send(p))
        end
      end
    end

    declare_action_class.class_eval do
      def svc_manager(&block)
        case manager
        when 'auto'
          svc = _service_manager(name, &block)
        when 'execute'
          svc = service_manager_execute(name, &block)
        when 'upstart'
          svc = service_manager_upstart(name, &block)
        when 'systemd'
          svc = service_manager_systemd(name, &block)
        end
        copy_properties_to(svc)
        svc
      end
    end

    action :start do
      svc_manager do
        action :start
      end
    end

    action :stop do
      svc_manager do
        action :stop
      end
    end

    action :restart do
      svc_manager do
        action :restart
      end
    end

    action :reload do
      svc_manager do
        action :reload
      end
    end

  end
end
