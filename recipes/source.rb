#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook Name:: transmission
# Recipe:: source
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

include_recipe 'build-essential'

version = node['transmission']['version']

build_pkgs = value_for_platform_family(
  %w(rhel fedora) => ['curl', 'curl-devel', 'libevent', 'libevent-devel', 'intltool', 'gettext', 'tar', 'xz', 'openssl-devel'],
  'default' => ['automake', 'libtool', 'pkg-config', 'libcurl4-openssl-dev', 'intltool', 'libxml2-dev', 'libgtk2.0-dev', 'libnotify-dev', 'libglib2.0-dev', 'libevent-dev', 'xz-utils']
)

build_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/transmission-#{version}.tar.xz" do
  source "#{node['transmission']['url']}/transmission-#{version}.tar.xz"
  checksum node['transmission']['checksum']
  action :create_if_missing
end

check_command = "/usr/local/bin/transmission-daemon -V 2>&1 | awk '{print $2}'"

execute 'compile-transmission' do
  cwd Chef::Config[:file_cache_path]
  command <<-EOH
    tar xvJf transmission-#{version}.tar.xz
    cd transmission-#{version}
    ./configure -q && make -s
    make install
  EOH
  not_if { ::File.exist?('/usr/local/bin/transmission-daemon') && Mixlib::ShellOut.new(check_command).run_command.stdout.chomp =~ /^#{version}/ }
  notifies :restart, 'service[transmission-daemon]', :delayed
end

group node['transmission']['group'] do
  action :create
end

include_recipe 'transmission::user'

directory node['transmission']['home'] do
  owner node['transmission']['user']
  group node['transmission']['dir_group']
  mode node['transmission']['dir_mode']
end

directory node['transmission']['config_dir'] do
  owner node['transmission']['user']
  group node['transmission']['dir_group']
  mode node['transmission']['dir_mode']
end

include_recipe 'transmission::default'
