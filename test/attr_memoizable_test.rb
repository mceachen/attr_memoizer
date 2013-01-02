require 'minitest_helper'

describe AttrMemoizable do

  before :each do
    Target.call_count = 0
  end

  class Target
    class << self
      attr_accessor :call_count
      attr_accessor :methods_added
    end

    self.methods_added = []
    self.call_count = 0

    def self.method_added(method_name)
      self.methods_added << method_name
      super
    end

    def already_defined_field
      "prething#{self.class.call_count += 1}"
    end

    include AttrMemoizable
    attr_memoizable :thing, :already_defined_field
    attr_memoizable :one_more_thing

    def thing
      "thing#{self.class.call_count += 1}"
    end

    def one_more_thing
      "iThing#{self.class.call_count += 1}"
    end
  end

  class TargetWithMethodsAddedAfter
    class << self
      attr_accessor :methods_added
      attr_accessor :call_count
    end

    self.methods_added = []
    self.call_count = 0

    include AttrMemoizable
    attr_memoizable :thing

    def self.method_added(method_name)
      self.methods_added << method_name
      super
    end

    def thing
      "thing#{self.class.call_count += 1}"
    end
  end

  it "doesn't call on initialize" do
    Target.new
    Target.call_count.must_equal 0
  end

  it "doesn't hide prior-defined method_added" do
    Target.methods_added.must_include_all [:already_defined_field, :thing, :one_more_thing]
  end

  it "doesn't hide post-defined method_added" do
    TargetWithMethodsAddedAfter.methods_added.must_include_all [:thing]
  end

  it "works for post-defined method_added classes" do
    t = TargetWithMethodsAddedAfter.new
    t.thing.must_equal "thing1"
    t.thing.must_equal "thing1"
  end

  it "works for already-defined fields" do
    t = Target.new
    t.already_defined_field.must_equal "prething1"
    t.already_defined_field.must_equal "prething1"
  end

  it "works for fields defined after attr_memoizable" do
    t = Target.new
    t.thing.must_equal "thing1"
    t.thing.must_equal "thing1"
  end

  it "works for multiple calls to attr_memoizable" do
    t = Target.new
    t.one_more_thing.must_equal "iThing1"
    t.one_more_thing.must_equal "iThing1"
    Target.new.one_more_thing.must_equal "iThing2"
  end

  it "doesn't pollute other instances" do
    targets = 3.times.collect { Target.new }
    targets.collect { |ea| ea.thing }.must_equal %w(thing1 thing2 thing3)
    Target.new.thing.must_equal "thing4"
    targets.collect { |ea| ea.thing }.must_equal %w(thing1 thing2 thing3)
  end
end
