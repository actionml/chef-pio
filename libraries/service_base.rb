module PIO
  class ServiceBase < Chef::Resource
    property :service_name, String, name_property: true
    property :variables, [Hash, Mash], default: {}

    property :user, String, default: 'root'
    property :group, String, default: 'root'

    def provided_service_variables
      self.variables.merge(
        user: user,
        group: group,
        java_home: node['java']['java_home']
      )
    end

    def restart_action
      supports[:reload] ? :reload : :restart
    end

  end
end
