#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook Name:: transmission
# Attribute:: default
#
# Copyright 2011, Chef Software, Inc.
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

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

case node['platform_family']
when 'debian'
  default['transmission']['install_method'] = 'package'
  default['transmission']['user']           = 'debian-transmission'
  default['transmission']['group']          = 'debian-transmission'
  default['transmission']['dir_group']      = 'debian-transmission'
else
  default['transmission']['install_method'] = 'source'
  default['transmission']['user']           = 'transmission'
  default['transmission']['group']          = 'transmission'
  default['transmission']['dir_group']      = 'transmission'
end

default['transmission']['url']              = 'http://download.transmissionbt.com/files'
default['transmission']['version']          = '2.84'
default['transmission']['checksum']         = 'a9fc1936b4ee414acc732ada04e84339d6755cd0d097bcbd11ba2cfc540db9eb'

default['transmission']['peer_port']              = 51_413
default['transmission']['max_peers_global']       = 200
default['transmission']['peer_limit_global']      = 240
default['transmission']['peer_limit_per_torrent'] = 60

default['transmission']['rpc_bind_address']            = '0.0.0.0'
default['transmission']['rpc_username']                = 'transmission'
default['transmission']['rpc_password']                = 'transmission'
default['transmission']['rpc_port']                    = 9091
default['transmission']['rpc_authentication_required'] = 'true'
default['transmission']['rpc_whitelist_enabled']       = 'true'
default['transmission']['rpc_whitelist']               = '127.0.0.1'

default['transmission']['home']             = '/var/lib/transmission-daemon'
default['transmission']['config_dir']       = '/var/lib/transmission-daemon/info'
default['transmission']['download_dir']     = '/var/lib/transmission-daemon/downloads'
default['transmission']['incomplete_dir']   = '/var/lib/transmission-daemon/incomplete'
default['transmission']['watch_dir']        = '/var/lib/transmission-daemon/watch'
default['transmission']['incomplete_dir_enabled'] = 'false'
default['transmission']['watch_dir_enabled']      = 'false'

default['transmission']['script_torrent_done_enabled']  = 'false'
default['transmission']['script_torrent_done_filename'] = ''

default['transmission']['speed_limit_down']         = 100 # KB/s
default['transmission']['speed_limit_down_enabled'] = 'false'
default['transmission']['speed_limit_up']           = 100 # KB/s
default['transmission']['speed_limit_up_enabled']   = 'false'

default['transmission']['umask']    = 18
default['transmission']['dir_mode'] = '0755'

default['transmission']['ratio_limit_enabled'] = 'false'
default['transmission']['ratio_limit']         = '2.0000'

default['transmission']['idle_seeding_limit_enabled'] = 'false'
default['transmission']['idle_seeding_limit']         = 30
