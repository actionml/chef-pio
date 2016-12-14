module PIO
  class ServiceManagerExecute < ServiceBase
    resource_name :service_manager_execute

    provides :_service_manager, os: 'linux'

    property :exec_command, [String, Symbol], required: true
    property :exec_logfile, String
    property :exec_procregex, String
    property :exec_cwd, String
    property :exec_env, Hash, default: {}

    def logfile
      exec_logfile ? exec_logfile : "/tmp/#{name}_execute.log"
    end

    def noop?
      case exec_command
      when Symbol
        exec_command == :noop or raise Chef::Exceptions::ValidationFailed, "exec_command either String or :noop"
      when String
        false
      end
    end

    def proc_regex
      exec_procregex.to_s.empty? ? exec_command : exec_procregex
    end

    action :start do
      return if noop?

      execute "start service #{name}" do
        command "#{exec_command} >> #{logfile} 2>&1 &"
        cwd exec_cwd

        user new_resource.user
        group new_resource.group
        environment exec_env

        not_if "ps -ef | grep -v grep | grep #{exec_procregex || exec_command}"
        action :run
      end
    end

    action :stop do
      return if noop?

      execute "stop service #{name}" do
        command <<-EOF
          ps -eo pid,command | grep -v grep | grep #{exec_procregex || exec_command} |
            sed -e 's/[ \\t]//' -e 's/\\([0-9]*\\).*/\\1/' | xargs kill
        EOF

        only_if "ps -eo pid,command | grep -v grep | grep #{exec_procregex || exec_command}"
        action :run
      end
    end

    action :restart do
      action_stop
      action_start
    end

    action :reload do
      action_stop
      action_start
    end

  end
end
