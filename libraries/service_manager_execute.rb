module PIO
  class ServiceManagerExecute < ServiceBase
    resource_name :service_manager_execute

    provides :_service_manager, os: 'linux'

    property :exec_command, [String, Symbol], required: true
    property :exec_logfile, String
    property :exec_procregex, String

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

        ## setting user and group doesn't work...
        # user user
        # group group

        not_if "ps -ef | grep -v grep | grep #{exec_procregex || exec_command}"
        action :run
      end
    end

    action :stop do
      return if noop?

      execute "stop service #{name}" do
        command <<-EOF
          ps -eo pid,command | grep -v grep | grep #{exec_procregex || exec_command}" |
            cut -f1 -d' ' | xargs kill
        EOF

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
