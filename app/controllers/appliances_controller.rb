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

require 'boxgrinder-core/helpers/appliance-config-helper'
require 'boxgrinder-core/models/appliance-config'

class AppliancesController < BaseController
  include AppliancesHelper

  layout 'actions'
  before_filter :load_object, :except => [ :create, :index ]
  before_filter :validate_appliance_definition_file, :only => [ :create ]

  def index
    @appliances = Appliance.all
    render_general( @appliances )
  end

  def show
    render_general( @appliance )
  end

  def create
    logger.info "Creating new Appliance..."

    if Appliance.count( :conditions => "name = '#{@appliance_config.name}'" ) > 0
      render_error( Error.new( "Appliance with name '#{@appliance_config.name}' already exists in repository." ) )
      return
    end

    @appliance            = Appliance.new
    @appliance.name       = @appliance_config.name
    @appliance.summary    = @appliance_config.summary
    @appliance.config     = @appliance_config.to_yaml
    @appliance.status     = Appliance::STATUSES[:created]

    return unless object_saved?( @appliance )

    #Appliance.add_definition( @appliance.name, @appliance_definition )

    render_general( @appliance, 'appliances/show' )

    logger.info "Appliance '#{@appliance.name}' created."
  end

  def destroy
    logger.info "Removing Appliance '#{@appliance.name}'..."

    @appliance.status = Appliance::STATUSES[:removing]

    # TODO remove artifacts from repository

    return unless object_saved?( @appliance )

    images_size   = @appliance.images.size
    #packages_size = @appliance.packages.size

    if images_size == 0 # and packages_size == 0
      @appliance.destroy
      logger.info "Appliance '#{@appliance.name}' removed."
    else
      render_error( Error.new( "There are #{images_size} images you need to remove first before you remove '#{@appliance.name}' appliance." ) )
      return
    end

    redirect_to appliances_path
  end

end
