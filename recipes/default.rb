#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook Name:: transmission
# Recipe:: default
#
# Copyright:: 2011-2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

service 'transmission-daemon' do
  supports restart: true, reload: true
  priority 90
  action :nothing
end

include_recipe "transmission::#{node['transmission']['install_method']}"

%w(bencode i18n transmission-simple activesupport).each do |pkg|
  chef_gem pkg do
    action :install
    compile_time true if Chef::Resource::ChefGem.method_defined?(:compile_time)
    not_if "/opt/chef/embedded/bin/gem list | grep -q #{pkg}"
  end
end

require 'transmission-simple'

service 'transmission' do
  service_name 'transmission-daemon'
  supports restart: true, reload: true
  priority 90
  action :nothing
end

template 'transmission-default' do
  case node['platform_family']
  when 'rhel', 'fedora'
    path '/etc/sysconfig/transmission-daemon'
  else
    path '/etc/default/transmission-daemon'
  end
  source 'transmission-daemon.default.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[transmission-daemon]', :delayed
end

template '/etc/init.d/transmission-daemon' do
  source 'transmission-daemon.init.erb'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, 'service[transmission-daemon]', :delayed
end

directory '/etc/transmission-daemon' do
  owner 'root'
  group node['transmission']['group']
  mode '0755'
end

source_settings_file = ::File.join(node['transmission']['config_dir'],'_settings.json')
dest_settings_file   = ::File.join(node['transmission']['config_dir'],'settings.json')

execute 'copy-settings-file-into-place' do
  command "cp #{source_settings_file} #{dest_settings_file}"
  not_if "diff #{source_settings_file} #{dest_settings_file}"
  action :nothing
  notifies :restart, 'service[transmission-daemon]', :delayed
end

execute 'forcefully-stop-and-copy' do
  command '/etc/init.d/transmission-daemon stop || true'
  action :nothing
  notifies :run, 'execute[copy-settings-file-into-place]', :immediately
end

template source_settings_file do
  source 'settings.json.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[forcefully-stop-and-copy]', :immediately
end

link '/etc/transmission-daemon/settings.json' do
  to "#{node['transmission']['config_dir']}/settings.json"
  not_if { File.symlink?("#{node['transmission']['config_dir']}/settings.json") }
  notifies :restart, 'service[transmission-daemon]', :delayed
end

service 'transmission-daemon' do
  supports restart: true, reload: true
  priority 90
  action [:enable, :start]
end
