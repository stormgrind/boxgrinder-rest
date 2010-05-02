require 'models/rest-config'

plugin_config_file = "#{Rails.root}/config/boxgrinder.yml"

if File.exists?(plugin_config_file)
  plugin_config = YAML.load_file(plugin_config_file)

  unless plugin_config.nil?
    ['platform', 'delivery'].each do |type|
      plugin_config['plugins'][type].each do |plugins|
        plugins.each { |plugin| BoxGrinder::RESTConfig.instance.register_plugin(plugin.to_s.downcase, type.to_sym) }
      end unless plugin_config['plugins'][type].nil?
    end unless plugin_config['plugins'].nil?

    plugin_config['operating_systems'].each do |name, versions|
      versions.each { |version| BoxGrinder::RESTConfig.instance.register_operating_system(name.downcase, version.to_s.downcase) }
    end unless plugin_config['operating_systems'].nil?

    plugin_config['architectures'].each do |arch|
      BoxGrinder::RESTConfig.instance.register_architecture(arch.downcase)
    end unless plugin_config['architectures'].nil?
  end
end

