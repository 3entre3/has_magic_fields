# frozen_string_literal: true

migrate = Rails&.version.to_i >= 5 ?
  ActiveRecord::Migration["#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"] :
    ActiveRecord::Migration

class AddHasMagicFieldsTables < migrate
  def change
    create_table :magic_fields do |t|
      t.column :name, :string
      t.column :label, :string
      t.column :datatype, :string, default: "string"
      t.column :default, :string
      t.column :required, :boolean, default: false
      t.column :include_blank, :boolean, default: false
      t.column :allow_other, :boolean, default: true
      t.column :type_scoped, :string
      t.timestamps
    end

    create_table :magic_attributes do |t|
      t.references :magic_field, foreign_key: true
      t.column :value, :string
      t.timestamps
    end

    create_table :magic_field_relationships do |t|
      t.references :magic_field, foreign_key: true
      t.references :owner, polymorphic: true
      t.column :name, :string
      t.column :type_scoped, :string
      t.timestamps
    end

    create_table :magic_attribute_relationships do |t|
      t.references :magic_attribute, foreign_key: true
      t.references :owner, polymorphic: true
      t.timestamps
    end

    add_index :magic_attribute_relationships, [:magic_attribute_id, :owner_id, :owner_type], name: "magic_attribute_id_owner", unique: true
    add_index :magic_field_relationships, [:magic_field_id, :owner_id, :owner_type], name: "magic_field_id_owner", unique: true
    add_index :magic_field_relationships, [:name, :type_scoped, :owner_id, :owner_type], name: "magic_field_name_owner", unique: true
  end
end
