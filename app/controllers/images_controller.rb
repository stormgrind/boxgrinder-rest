require 'boxgrinder-core/models/task'
require 'boxgrinder-core/models/appliance-config'
require 'boxgrinder-core/helpers/queue-helper'

class ImagesController < BaseController
  include ImagesHelper

  layout 'actions'

  before_filter :load_image, :except => [:create, :index]

  def index
    @images = Image.all
    render_general(@images)
  end

  # shows selected image in different formats
  def show
    render_general(@image)
  end

  def deliver
    param_delivery = params[:delivery] || nil

    puts @image

    render_general(@image, 'images/show')
  end

  def convert
    param_platform = params[:platform] || nil

    platform = nil

    unless param_platform.nil?
      unless BoxGrinder::RESTConfig.instance.plugins[:platform].include?(param_platform.downcase)
        render_error(Error.new("Invalid format specified. Available formats: #{BoxGrinder::RESTConfig.instance.plugins[:platform].sort.join(", ")}."))
        return
      end
      platform = param_platform.downcase
    end

    image = Image.last(
            :conditions => {
                    :parent_id      => @image.id,
                    :platform       => platform
            }
    )

    if image.nil?
      image = Image.new(
              :appliance        => @image.appliance,
              :parent           => @image,
              :arch             => @image.arch,
              :platform         => platform,
              :description      => "Image for #{@image.appliance.name} appliance, #{platform} platform and #{@image.arch} architecture."
      )

      begin
        ActiveRecord::Base.transaction do
          return unless object_saved?(image)

          BoxGrinder::QueueHelper.new( :log => logger ).client do |client|
            client.send("/queues/boxgrinder/image/convert",
                        :object => BoxGrinder::Task.new(
                                :convert,
                                image.description, {
                                        :appliance_config   => YAML.load(@image.appliance.config),
                                        :platform           => platform,
                                        :image_id           => image.id
                                }),
                        :properties => { :node => @image.node.name }
            )

          end
        end
      rescue
        @log.error "Couldn't send message to #{@image.node.name} node."
      end

    end

    @image = image

    render_general(@image, 'images/show')
  end

  def create
    param_appliance_id  = params[:appliance_id] || nil
    param_arch          = params[:arch]         || nil

    if param_appliance_id.nil? or !param_appliance_id.match(/\d+/)
      render_error(Error.new("No or invalid 'appliance_id' parameter specified."))
      return
    end

    if param_arch.nil? or !BoxGrinder::SUPPORTED_ARCHES.include?(param_arch)
      render_error(Error.new("No or invalid 'arch' parameter specified. Valid parameters are: #{BoxGrinder::SUPPORTED_ARCHES.join(", ")}."))
      return
    end

    # 1.check if there is already a built image
    @image = Image.last(
            :conditions => {
                    :appliance_id   => param_appliance_id,
                    :platform       => nil
            }
    )

    if @image.nil?
      begin
        appliance         = Appliance.find(param_appliance_id)
        appliance_config  = YAML.load(appliance.config)
      rescue => e
        render_error(Error.new("Something went wrong, check logs for more info.", e))
        return
      end

      if appliance.status != Appliance::STATUSES[:created]
        render_error(Error.new("Appliance '#{appliance.name}' has invalid status (#{appliance.status}). Image can be built only for appliances in status #{Appliance::STATUSES[:created]}."))
        return
      end

      @image = Image.new(
              :appliance_id     => appliance.id,
              :arch             => param_arch,
              :description      => "Base image for #{appliance.name} appliance and #{param_arch} architecture."
      )

      return unless object_saved?(@image)

      BoxGrinder::QueueHelper.new( :log => logger ).client do |client|
        client.send("/queues/boxgrinder/image/create",
                    :object => BoxGrinder::Task.new(
                            :create,
                            @image.description, {
                                    :appliance_config   => appliance_config,
                                    :image_id           => @image.id
                            }),
                    :properties => {
                            :os_name     => appliance_config.os.name,
                            :os_version  => appliance_config.os.version,
                            :arch        => param_arch
                    }
        )
      end
    end

    render_general(@image, 'images/show')
  end

  def destroy
    unless [Image::STATUSES[:new], Image::STATUSES[:built], Image::STATUSES[:error]].include?(@image.status)
      render_error(Error.new("Current image status (#{@image.status}) doesn't allow to remove it. Try again later."))
      return
    end

    logger.info "Removing image with id = #{@image.id}..."

    to_remove = @image.images + [ @image ]

    begin
      ActiveRecord::Base.transaction do
        BoxGrinder::QueueHelper.new( :log => logger ).client do |client|
          to_remove.each do |image|
            client.send("/queues/boxgrinder/image/destroy",
                        :object => BoxGrinder::Task.new(
                                :destroy,
                                "Removing image with id = #{image.id}", {
                                        :appliance_config   => YAML.load(image.appliance.config),
                                        :platform           => image.platform,
                                        :image_id           => image.id
                                }),
                        :properties => { :node => image.node.name }
            ) unless image.node.nil?
          end
        end

        @image.destroy
      end
    rescue => e
      render_error(Error.new("An error occurred while destroying image. See logs for more info.", e))
      return
    end

    logger.info "Image with id = #{@image.id} removed."

    redirect_to images_path
  end
end
