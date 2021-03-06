# frozen_string_literal: true

class MagicAttributeRelationship < ActiveRecord::Base
  belongs_to :magic_attribute
  belongs_to :owner, polymorphic: true
end
