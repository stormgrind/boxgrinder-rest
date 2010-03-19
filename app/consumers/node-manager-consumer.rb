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

module BoxGrinder
  module REST
    class ImageManagerConsumer

      def on_object( payload )
        @log = Rails.logger

        @log.info "Received new management message for Node."

        node = payload[:node]

        case payload[:action]
          when :register then
            register_node( node )
          when :deregister then
            deregister_node( node )
        end

        @log.info "Message handled."
      end

      def register_node( node )
        @log.info "Registering node #{node[:address]} (arch = #{node[:arch]}, os = #{node[:os_name]} #{node[:os_version]})..."
        begin

          @log.info "Node #{node[:address]} registered."
        rescue
          @log.info "An error occurred while registering node #{node[:address]}."
        end
      end

      def deregister_node( node )

      end
    end
  end
end