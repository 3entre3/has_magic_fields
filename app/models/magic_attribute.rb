# frozen_string_literal: true

# Always work through the interface MagicAttribute.value
class MagicAttribute < ActiveRecord::Base
  belongs_to :magic_field

  before_save :set_value

  def to_s
    value.to_s
  end

  def set_value
    return if ["integer"].include?(magic_field.datatype)

    self.value = magic_field.serialize_value(value)
  end
end
