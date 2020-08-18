# frozen_string_literal: true

class MagicField < ActiveRecord::Base
  has_many :magic_field_relationships, dependent: :destroy
  has_many :owners, through: :magic_field_relationships, as: :owner
  has_many :magic_attributes, dependent: :destroy

  validates_presence_of :name, :datatype
  validates_format_of :name, with: /\A[a-z][a-z0-9_]+\z/

  before_save :set_label

  def type_cast(value)
    type = ActiveRecord::Type.lookup(datatype.to_sym)
    ActiveModel::Attribute.from_database(name, value, type).value
  rescue
    value
  end

  def set_label
    self.label = name.humanize if label.blank?
  end
end
