user node['transmission']['user'] do
  comment 'Transmission Daemon User'
  gid node['transmission']['group']
  system true
  home node['transmission']['home']
  action :create
end
