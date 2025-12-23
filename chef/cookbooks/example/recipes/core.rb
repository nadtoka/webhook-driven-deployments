directory '/etc/webhook-driven-deployments' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

if platform_family?('debian')
  apt_update 'example_core_update' do
    action :update
  end
end

marker = node['example']['marker']
file '/etc/webhook-driven-deployments/core.txt' do
  content "Suite: core\nMarker: #{marker}\nTimestamp: #{Time.now.utc}\n"
  owner 'root'
  group 'root'
  mode '0644'
end

log 'example::core completed placeholder converge' do
  level :info
end
