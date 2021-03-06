#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook Name:: transmission
# Library:: torrent
#
# Copyright:: 2011-2015, Chef Software, Inc. <legal@chef.io>
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

begin
  require 'ostruct'
  require 'transmission-simple'
rescue LoadError
end

# all your monkey patches are belong to us
module TransmissionSimple
  class Torrent < OpenStruct
    STATUS_CODES = {
      1 => 'CHECK_WAIT',
      2 => 'CHECK',
      4 => 'DOWNLOAD',
      8 => 'SEED',
      16 => 'STOPPED'
    }.freeze

    def downloading?
      status == STATUS_CODES.key('DOWNLOAD')
    end

    def stopped?
      status == STATUS_CODES.key('STOPPED')
    end

    def checking?
      status == STATUS_CODES.key('CHECK') || status == STATUS_CODES.key('CHECK_WAIT')
    end

    def seeding?
      status == STATUS_CODES.key('SEED')
    end

    def status_message
      STATUS_CODES[status]
    end
  end
end

module Opscode
  module Transmission
    class Client
      DEFAULT_RESPONSE_FIELDS = %w(id name status totalSize percentDone startDate hashString downloadDir files).freeze

      def initialize(endpoint)
        @transmission = TransmissionSimple::Api.new(endpoint)
      end

      def get_torrent(torrent_hash)
        @transmission.send_request('torrent-get', ids: [torrent_hash], fields: DEFAULT_RESPONSE_FIELDS).first
      end

      def add_torrent(torrent_file)
        t = @transmission.send_request('torrent-add', filename: torrent_file)['torrent-added']
        TransmissionSimple::Torrent.new(t)
      end

      def remove_torrent(torrent_hash, delete_data = false)
        @transmission.send_request('torrent-remove', 'ids' => [torrent_hash], 'delete-local-data' => delete_data)
      end
    end
  end
end
