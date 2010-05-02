require 'singleton'

module BoxGrinder
  class RESTConfig
    include Singleton

    def initialize
      @plugins            = {}
      @operating_systems  = {}
      @architectures      = []
    end

    def register_plugin(name, type)
      @plugins[type] = [] if @plugins[type].nil?

      begin
        @plugins[type] << name
      rescue
        raise "Not supported plugin type: #{type}"
      end
    end

    def register_operating_system(name, version)
      @operating_systems[name] = [] if @operating_systems[name].nil?

      @operating_systems[name] << version
    end

    def register_architecture(arch)
      @architectures << arch
    end

    attr_reader :plugins
    attr_reader :architectures
    attr_reader :operating_systems
  end
end