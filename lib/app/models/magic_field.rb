class MagicField < ActiveRecord::Base
  has_many :magic_field_relationships, :dependent => :destroy
  has_many :owners, :through => :magic_field_relationships, :as => :owner
  has_many :magic_attributes, :dependent => :destroy
  
  validates_presence_of :name, :datatype
  validates_format_of :name, :with => /\A[a-z][a-z0-9_]+\z/

  before_save :set_pretty_name

  def type_cast(value)
    type = ActiveRecord::Type.lookup(datatype.to_sym)
    ActiveModel::Attribute.from_database(name, value, type).value
  rescue
    value
  end

  # Display a nicer (possibly user-defined) name for the column or use a fancified default.
  def set_pretty_name
    self.pretty_name = name.humanize if  pretty_name.blank?
  end
end
