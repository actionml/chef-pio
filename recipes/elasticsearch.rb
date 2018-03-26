elasticsearch_user 'elasticsearch'
elasticsearch_install 'elasticsearch'

elasticsearch_configure 'elasticsearch' do
  node['elasticsearch']['configure'].each do |key, value|
    # Skip nils, use false if you want to disable something.
    send(key, value) unless value.nil?
  end
end

## We can't start ES (ex. a systemd service) when we run in Docker on CIs
#
elasticsearch_service 'elasticsearch' do
  node['elasticsearch']['service'].each do |key, value|
    # Skip nils, use false if you want to disable something.
    send(key, value) unless value.nil?
  end

  action [:configure] | service_actions
  not_if { docker? || node['pio']['provision_only'] }
end

# Use execute service_manager to start the ElasticSearch
service_manager 'elasticsearch' do
  supports status: true, reload: false
  user  'elasticsearch'
  group 'elasticsearch'

  exec_command('/usr/share/elasticsearch/bin/elasticsearch'\
               ' -Edefault.path.data=/var/lib/elasticsearch '\
               ' -Edefault.path.conf=/etc/elasticsearch')

  exec_procregex 'org.elasticsearch.bootstrap.Elasticsearch'

  only_if { docker? }
  manager :execute

  action service_actions
end

# by default, no plugins
node['elasticsearch']['plugin'].each do |plugin_name, plugin_value|
  elasticsearch_plugin plugin_name do
    plugin_value.each do |key, value|
      # Skip nils, use false if you want to disable something.
      send(key, value) unless value.nil?
    end
  end
end
