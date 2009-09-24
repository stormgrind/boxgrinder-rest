module ConversionHelper
  def convert_to_yaml( o )
    if o.class.eql?(Array)
      a = []
      for item in o
        a.push item.attributes
      end
      a.to_yaml
    else
      o.class.ancestors.include?(ActiveRecord::Base) ? o.attributes.to_yaml : o.to_yaml
    end
  end
end