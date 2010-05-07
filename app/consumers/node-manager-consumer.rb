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

      def on_object( payload, message )
        @log = Rails.logger

        @log.info "Received new management message for Node artifact from node."
        @log.trace payload.to_yaml

        unless payload.is_a?(Hash) or payload[:node].nil? or message.jmsreply_to.nil?
          @log.error "Invalid message received."
          return
        end

        @reply_to = message.jmsreply_to

        case payload[:action]
          when :register
            register_node( payload[:node] )
          when :unregister
            unregister_node( payload[:name] )
        end
      end

      def register_node( node_config )
        unless node_config.is_a?(Hash)
          @log.error "Invalid node configuration received."
          return
        end

        begin
          node = Node.last( :conditions => { :name  => node_config[:name] } )

          unless node.nil?
            @log.info "Node '#{node.name}' is already registered, updating status."
          else
            node = Node.new( node_config )
          end

          node.status = Node::STATUSES[:active]

          @log.info "Registering node '#{node.name}'."

          ActiveRecord::Base.transaction do
            node.save!
          end

          reply_ok

          @log.info "Node registered."
        rescue => e
          @log.error e
          @log.error e.backtrace.join($/)
          @log.error "Couldn't register node '#{node_config[:name]}'."
        end
      end

      def unregister_node( name )
        @log.info "Unregistering node '#{name}'."

        begin
          node = Node.last( :conditions => { :name  => name } )

          unless node.nil?
            node.status = Node::STATUSES[:inactive]

            ActiveRecord::Base.transaction do
              node.save!
            end
          end

          reply_ok

          @log.info "Node '#{name}' unregistered."
        rescue => e
          @log.error e
          @log.error e.backtrace.join($/)
          @log.error "Couldn't unregister node '#{name}'."
        end
      end

      def reply_ok
        TorqueBox::Messaging::Client.connect do |client|
          client.send(@reply_to, :text => 'OK')
        end
      end

    end
  end
end
