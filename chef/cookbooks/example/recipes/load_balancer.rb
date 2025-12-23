directory '/etc/webhook-driven-deployments' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

if platform_family?('debian')
  apt_update 'example_load_balancer_update' do
    action :update
  end
end

marker = node['example']['marker']
file '/etc/webhook-driven-deployments/load_balancer.txt' do
  content "Suite: load_balancer\nMarker: #{marker}\nTimestamp: #{Time.now.utc}\n"
  owner 'root'
  group 'root'
  mode '0644'
end

log 'example::load_balancer completed placeholder converge' do
  level :info
end
