module PIO
  class ServiceBase < Chef::Resource
    property :service_name, String, name_property: true
    property :variables, [Hash, Mash], default: {}

    property :user, String, default: 'root'
    property :group, String, default: 'root'

    property :provision_only, [TrueClass, FalseClass], default: false
    alias :provision_only? :provision_only

    def provided_service_variables
      self.variables.merge(
        user: user,
        group: group,
        java_home: node['java']['java_home']
      )
    end

    def reload_action
      supports[:reload] ? :reload : :restart
    end

  end
end
