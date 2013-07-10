class Product

  Products = {}

  attr_reader :family, :model_number, :model, :cpu, :capabilities, :name

  def initialize(product_name, serial = '')
    family, family_information = Products.select do |family|
      product_name =~ /^#{family}/
    end.first
    @family = family_information[:name]
    model_match = family_information[:models].select do |model_number|
      serial.last(3) == model_number
    end.first
    model_match ||= family_information[:models].select do |model_number|
      product_name == "#{family}#{model_number}"
    end.first
    @model_number, (@model, @cpu, @capabilities) = model_match
    @name = [@family, @model].compact.join ' '
  end

  def to_s
    name
  end

end
