# JBoss, Home of Professional Open Source
# Copyright 2009, Red Hat Middleware LLC, and individual contributors
# by the @authors tag. See the copyright.txt in the distribution for a
# full listing of individual contributors.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

require 'torquebox-messaging-client'

module BoxGrinder
  module REST
    class NodeManagerConsumer

      def on_object(payload, message)
        @log = Rails.logger
        @reply_to = message.jmsreply_to

        if @reply_to.nil? or !payload.is_a?(Hash)
          @log.error "Invalid data sent to register a node."
          return
        end

        case payload[:action]
          when :register
            register_node(payload[:node])
        end
      end

      def register_node(node_config)
        @log.info "Registering new node..."
        @log.debug "New node name: '#{node_config[:name]}'"

        # TODO save this to database
        # node_config[:address]
        # node_config[:os_name]
        # node_config[:os_version]
        # node_config[:arch]

        begin
          TorqueBox::Messaging::Client.connect do |client|
            client.send(@reply_to, :text => 'OK')
          end
          @log.info "New node registered."
        rescue => e
          @log.error e
          @log.error e.backtrace.join($/)
          @log.error "Couldn't register node '#{node_config[:name]}'."
        end
      end
    end
  end
end
