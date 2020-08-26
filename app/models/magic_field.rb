# frozen_string_literal: true

class MagicField < ActiveRecord::Base
  has_many :magic_field_relationships, dependent: :destroy
  has_many :owners, through: :magic_field_relationships, as: :owner
  has_many :magic_attributes, dependent: :destroy

  validates_presence_of :name, :datatype
  validates_format_of :name, with: /\A[a-z][a-z0-9_]+\z/

  before_save :set_label

  def serialize_value(value)
    find_type.serialize(value).to_s
  end

  def type_cast(value)
    find_type.cast(value)
  end

  private

  def set_label
    self.label = name.humanize if label.blank?
  end

  def find_type
    ActiveRecord::Type.lookup(datatype.to_sym)
  end
end
