require 'prawn/measurement_extensions'

class Numeric

  def percent
    "#{self}%"
  end
end
