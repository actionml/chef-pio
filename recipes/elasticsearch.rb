
# Don't use elasticsearch service on docker
if docker?
  node.default['elasticsearch']['service']['action'] = :nothing
else
  node.default['elasticsearch']['service']['action'] = [:configure] + service_actions
end

include_recipe 'elasticsearch'

## Use execute service_manager to start the ElasticSearch
#  ONLY ON DOCKER!
#
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
