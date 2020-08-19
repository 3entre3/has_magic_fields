# frozen_string_literal: true

require "active_support"
require "active_record"

module HasMagicFields
  module Extend
    extend ActiveSupport::Concern
    include ActiveModel::Validations
    module ClassMethods
      def has_magic_fields(options = {})
        # Associations
        has_many :magic_attribute_relationships, as: :owner, dependent: :destroy
        has_many :magic_attributes, autosave: true, through: :magic_attribute_relationships, dependent: :destroy

        # Inheritence
        cattr_accessor :inherited_from

        # if options[:through] is supplied, treat as an inherited relationship
        if self.inherited_from = options[:through]
          class_eval do
            def inherited_magic_fields
              raise "Cannot inherit MagicFields from a non-existant association: #{@inherited_from}" unless self.class.method_defined?(inherited_from)
              inherited = send(inherited_from)
              return MagicField.none unless inherited.present?

              inherited.magic_fields
            end
          end
          alias_method :magic_fields, :inherited_magic_fields unless method_defined?(:magic_fields)

        # otherwise the calling model has the relationships
        else
          has_many :magic_field_relationships, as: :owner, dependent: :destroy
          has_many :magic_fields, through: :magic_field_relationships, dependent: :destroy
          # alias_method_chain :magic_fields, :scoped
        end
        alias_method  :magic_fields_without_scoped, :magic_fields
      end
    end

    included do
      def create_magic_field(options = {})
        type_scoped = options[:type_scoped].blank? ? self.class.name : options[:type_scoped].classify
        self.magic_fields.create(options.merge(type_scoped: type_scoped))
      end

      def magic_field_names(type_scoped = nil)
        magic_fields_with_scoped(type_scoped).map(&:name)
      end

      def magic_fields_with_scoped(type_scoped = nil)
        type_scoped = type_scoped.blank? ? self.class.name : type_scoped.classify
        magic_fields_without_scoped.where(type_scoped: type_scoped)
      end

      def method_missing(method_id, *args)
        method_name = method_id.to_s

        if method_name.end_with?("=")
          var_name = method_name.delete("=")
          value = args.first
          write_magic_attribute(var_name, value)
        else
          read_magic_attribute(method_name)
        end
      rescue NoMethodError
        super
      end

      def read_attribute_for_validation(attribute)
        super if attributes.include?(attribute) || magic_attributes.present?
      end

      def respond_to_missing?(method_id, include_private = false)
        method_name = method_id.to_s.delete("=")
        magic_field_names.include?(method_name) || super
      end

      def valid?(context = nil)
        output = super(context)
        magic_fields_with_scoped.each do |field|
          if field.required?
            validates_presence_of(field.name)
          end
        end
        errors.empty? && output
      end

      private

      def create_magic_attribute(magic_attribute, value)
        magic_attributes.build(magic_field: magic_attribute.magic_field, value: value)
        magic_attribute
      end

      def find_magic_attribute_by_field(field)
        magic_attributes.to_a.find { |attr| attr.magic_field_id == field.id }
      end

      def find_magic_field_by_name(attr_name)
        magic_fields_with_scoped.to_a.find { |column| column.name == attr_name }
      end

      def find_or_initialize_magic_attribute!(field_name)
        field = find_magic_field_by_name(field_name)
        raise NoMethodError unless field.present?

        attribute = find_magic_attribute_by_field(field)
        attribute || MagicAttribute.new(magic_field: field)
      end

      def in_magic_attributes?(attribute)
        attribute.persisted? || magic_attributes.include?(attribute)
      end

      def read_magic_attribute(field_name)
        attribute = find_or_initialize_magic_attribute!(field_name)
        value = attribute.value.presence || attribute.magic_field.default
        return unless value.present?

        attribute.magic_field.type_cast(value)
      end

      def update_magic_attribute(magic_attribute, value)
        magic_attribute.value = value
        magic_attribute
      end

      def write_magic_attribute(field_name, value)
        attribute = find_or_initialize_magic_attribute!(field_name)
        return update_magic_attribute(attribute, value) if in_magic_attributes?(attribute)

        create_magic_attribute(attribute, value)
      end
    end

    %w[models].each do |dir|
      path = File.join(File.dirname(__FILE__), "../app", dir)
      $LOAD_PATH << path
      ActiveSupport::Dependencies.autoload_paths << path
      ActiveSupport::Dependencies.autoload_once_paths.delete(path)
    end
  end
end
