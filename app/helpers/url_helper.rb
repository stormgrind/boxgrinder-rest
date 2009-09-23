module UrlHelper

  def valid_format?
    formats = [ "json", "yaml", "xml" ]

    return true if params[:format].nil?
    return formats.include?( params[:format] )
  end

  def root_action?( path )
    unless request.path.match(/^(.*)\/$/).nil?
      rp = request.path.match(/^(.*)\/$/)[1]
    else
      rp = request.path
    end

    puts path
    puts rp

    path.eql?( rp )
  end
end
