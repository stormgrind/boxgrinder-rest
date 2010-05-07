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
      def on_object(image)
        @log = Rails.logger

        @log.info "Received new management message for Image artifact from node."
        @log.trace image.to_yaml

        unless image.is_a?(Hash) or image[:id].nil? or image[:status].nil?
          @log.error "Invalid message received."
          return
        end

        begin
          @image = Image.find(image[:id])

          unless Image::STATUSES.include?(image[:status])
            @log.error "Unrecognized or no status sent: '#{image[:status]}', couldn't update image!"
            return
          end

          @image.status = Image::STATUSES[image[:status]]

          if @image.status == Image::STATUSES[:building]
            if image[:node].nil?
              @log.error "No node specified, couldn't update image!"
              return
            end

            node = Node.last( :conditions => { :name  => image[:node] } )

            if node.nil?
              @log.error "Node '#{image[:node]}' not found. Is node properly registered?"
              return
            else
              @image.node = node
            end
          end

          ActiveRecord::Base.transaction do
            @image.save!
          end

          @log.info "Image #{image[:id]} status updated: #{image[:status]}."
        rescue => e
          @log.error e.info
          @log.error "Couldn't update status update for image artifact. Image"
        end
      end
    end
  end
end