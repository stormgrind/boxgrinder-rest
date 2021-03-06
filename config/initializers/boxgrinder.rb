require 'models/rest-config'

log = ActiveRecord::Base.logger

plugin_config_file = "#{Rails.root}/config/boxgrinder.yml"

if File.exists?(plugin_config_file)
  plugin_config = YAML.load_file(plugin_config_file)
  return if plugin_config.nil?

  log.info "Preparing BoxGrinder REST server..."

  ['platform', 'delivery'].each do |type|

    log.info "Registering #{type} plugins..."

    plugin_config['plugins'][type].each do |plugins|
      plugins.each do |plugin|
        log.info "- #{plugin}"
        BoxGrinder::RESTConfig.instance.register_plugin(plugin.to_s.downcase, type.to_sym)
      end
    end unless plugin_config['plugins'][type].nil?
  end unless plugin_config['plugins'].nil?

  plugin_config['operating_systems'].each do |name, versions|

    log.info "Registering operating system plugin for #{name} #{versions.join(', ')}..."

    versions.each do |version|
      BoxGrinder::RESTConfig.instance.register_operating_system(name.downcase, version.to_s.downcase)
    end
  end unless plugin_config['operating_systems'].nil?

  plugin_config['architectures'].each do |arch|
    log.info "Registering #{arch} architecture..."
    BoxGrinder::RESTConfig.instance.register_architecture(arch.downcase)
  end unless plugin_config['architectures'].nil?

  log.info "BoxGrinder REST server prepared."
end

