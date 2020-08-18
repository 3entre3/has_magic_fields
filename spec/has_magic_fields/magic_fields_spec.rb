# frozen_string_literal: true

require "spec_helper"

describe HasMagicFields do
  context "on a single model" do
    before(:each) do
      @charlie = Person.create(name: "charlie")
    end

    it "initializes magic fields correctly" do
      expect(@charlie).not_to be(nil)
      expect(@charlie.class).to be(Person)
      expect(@charlie.magic_fields).not_to be(nil)
    end

    it "allows adding a magic field" do
      @charlie.create_magic_field(name: "salary")

      expect(@charlie.magic_fields.length).to eq(1)
    end

    it "validates_uniqueness_of name in a object" do
      @charlie.create_magic_field(name: "salary")

      before_fields_count = MagicField.count
      expect(@charlie.magic_fields.length).to eq(1)
      expect { @charlie.create_magic_field(name: "salary") }.to raise_error
      expect(@charlie.magic_fields.length).to eq(1)

      after_fields_count = MagicField.count
      expect(before_fields_count).to eq(after_fields_count)
    end

    it "allows setting and saving of magic attributes" do
      @charlie.create_magic_field(name: "salary")
      @charlie.salary = 50000
      @charlie.save
      @charlie = Person.find(@charlie.id)

      expect(@charlie.salary).not_to be(nil)
    end

    it "forces required if required is true" do
      @charlie.create_magic_field(name: "last_name", required: true)

      expect(@charlie.save).to be(false)
      @charlie.last_name = "zongsi"
      expect(@charlie.save).to be(true)
    end

    it "allows datatype to be :date" do
      @charlie.create_magic_field(name: "birthday", datatype: :date)
      @charlie.birthday = Date.today

      expect(@charlie.save).to be(true)
      expect(@charlie.birthday.class.name).to eq("Date")
    end

    it "allows datatype to be :datetime" do
      @charlie.create_magic_field(name: "signed_up_at", datatype: :datetime)
      @charlie.signed_up_at = DateTime.now

      expect(@charlie.save).to be(true)
      expect(@charlie.signed_up_at.class.name).to eq("Time")
    end

    it "allows datatype to be :integer" do
      @charlie.create_magic_field(name: "age", datatype: :integer)
      @charlie.age = 5

      expect(@charlie.save).to be(true)
      expect(@charlie.age.class.name).to eq("Integer")
    end

    it "casts datatype to :integer" do
      @charlie.create_magic_field(name: "age", datatype: :integer)
      @charlie.age = "no_integer"

      expect(@charlie.save).to be(true)
      expect(@charlie.age).to eq(0)
    end

    it "allows datatype to be :boolean" do
      @charlie.create_magic_field(name: "retired", datatype: :boolean)
      @charlie.retired = false

      expect(@charlie.save).to be(true)
      expect(@charlie.retired).to be(false)
    end

    it "allows datatype to be :boolean valid" do
      @charlie.create_magic_field(name: "retired", datatype: :boolean)
      @charlie.retired = "t"

      expect(@charlie.save).to be(true)
      expect(@charlie.retired).to be(true)
    end

    it "allows datatype to be :float" do
      @charlie.create_magic_field(name: "number", datatype: :float)
      @charlie.number = "10.51"

      expect(@charlie.save).to be(true)
      expect(@charlie.number).to be(10.51)
    end

    it "allows default to be set" do
      @charlie.create_magic_field(name: "bonus", default: "40000")

      expect(@charlie.bonus).to eq("40000")
    end

    it "allows a pretty display name to be set" do
      @charlie.create_magic_field(name: "zip", label: "Zip Code")

      expect(@charlie.magic_fields.last.label).to eq("Zip Code")
    end

    it "allows to be reloaded" do
      @charlie.create_magic_field(name: "age", datatype: :integer)
      @charlie.age = 12
      @charlie.save

      expect(@charlie.reload.age).to eq(12)
    end
  end

  context "in a parent-child relationship" do
    before(:each) do
      @account = Account.create(name: "important")
      @alice = User.create(name: "alice", account: @account)
      @product = Product.create(name: "TR", account: @account)
    end

    it "initializes magic fields correctly" do
      expect(@alice).not_to be(nil)
      expect(@alice.class).to be(User)
      expect(@alice.magic_fields).not_to be(nil)

      expect(@account).not_to be(nil)
      expect(@account.class).to be(Account)
      expect(@alice.magic_fields).not_to be(nil)
    end

    it "allows adding a magic field from the child" do
      @alice.create_magic_field(name: "salary")

      expect(@alice.magic_fields.length).to eq(1)
      expect { @alice.salary }.not_to raise_error
      expect { @account.salary }.to raise_error
    end

    it "allows adding a magic field from the parent" do
      @account.create_magic_field(name: "age", type_scoped: "User")

      expect { @alice.age }.not_to raise_error
    end

    it "sets magic fields for all child models" do
      @bob = User.create(name: "bob", account: @account)
      @bob.create_magic_field(name: "birthday")

      expect { @alice.birthday }.not_to raise_error

      @bob.birthday = "2014-07-29"

      expect(@bob.save).to be(true)
      expect(@alice.birthday).to be(nil)

      @alice.birthday = "2013-07-29"

      expect(@alice.save).to be(true)
      expect(@alice.birthday).not_to eq(@bob.birthday)
    end

    it "defferent model has defferent scope" do
      @alice.create_magic_field(name: "salary")

      expect { @alice.salary }.not_to raise_error
      expect { @product.salary }.to raise_error
    end

    it "validates_uniqueness_of name in all models object" do
      @alice.create_magic_field(name: "salary")
      before_fields_count = MagicField.count

      expect(@alice.magic_fields.length).to eq(1)
      expect { @alice.create_magic_field(name: "salary") }.to raise_error
      expect(@alice.magic_fields.length).to eq(1)
      expect(before_fields_count).to eq(MagicField.count)

      @bob = User.create(name: "bob", account: @account)

      expect { @bob.create_magic_field(name: "salary") }.to raise_error
      expect { @product.create_magic_field(name: "salary") }.not_to raise_error
      expect { @account.create_magic_field(name: "salary") }.not_to raise_error
    end
  end
end
