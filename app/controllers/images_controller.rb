require 'boxgrinder-core/models/task'

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

  def create
    param_appliance_id  = params[:appliance_id] || nil
    param_platform      = params[:platform] || nil
    param_arch          = params[:arch] || nil

    if param_appliance_id.nil? or !param_appliance_id.match(/\d+/)
      render_error(Error.new("No or invalid 'appliance_id' parameter specified."))
      return
    end

    if param_arch.nil? or !BoxGrinder::SUPPORTED_ARCHES.include?(param_arch)
      render_error(Error.new("No or invalid 'arch' parameter specified. Valid parameters are: #{BoxGrinder::SUPPORTED_ARCHES.join(", ")}."))
      return
    end

    platform = nil

    # image_format is optional, if no image_format parameter is specified; RAW format will be used
    unless param_platform.nil?
      unless BoxGrinder::RESTConfig.instance.plugins[:platform].include?(param_platform.downcase)
        render_error(Error.new("Invalid format specified. Available formats: #{BoxGrinder::RESTConfig.instance.plugins[:platform].sort.join(", ")}."))
        return
      end
      platform = param_platform.downcase
    end

    # 1.check if there is already a built image
    @image = Image.last(
            :conditions => {
                    :appliance_id   => param_appliance_id,
                    :platform       => platform
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
        render_error(Error.new("Appliance '#{appliance.name}' is in invalid status (#{appliance.status}). Image can be built only for appliances in status #{Appliance::STATUSES[:created]}."))
        return
      end

      @image = Image.new(
              :appliance_id     => appliance.id,
              :platform         => platform,
              :arch             => param_arch,
              :description      => "Image for #{appliance.name} appliance, #{param_arch} architecture#{platform.nil? ? '' : ", #{platform} platform"}."
      )

      return unless object_saved?(@image)

      enqueue_task("/queues/boxgrinder/#{appliance_config.os.name}/#{appliance_config.os.version}/#{param_arch}/image",
                   BoxGrinder::Task.new(:build, @image.description, {
                           :appliance_config   => appliance_config,
                           :platform           => @image.platform,
                           :image_id           => @image.id
                   })
      )
    end

    render_general(@image, 'images/show')
  end

  def destroy
    unless [Image::STATUSES[:new], Image::STATUSES[:built], Image::STATUSES[:error]].include?(@image.status)
      render_error(Error.new("Current image status (#{@image.status}) doesn't allow to remove it. Try again later."))
      return
    end

    logger.info "Removing image with id = #{@image.id}..."

    begin
      @image.destroy
    rescue => e
      render_error(Error.new("An error occurred while destroying image. See logs for more info.", e))
      return
    end

    logger.info "Image with id = #{@image.id} removed."

    redirect_to images_path
  end
end
