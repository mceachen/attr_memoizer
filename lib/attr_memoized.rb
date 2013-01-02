require "attr_memoized/version"

module AttrMemoized
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def attr_memoized(*attrs)
      # OMG 1.8.7 RETURNS STRINGS
      instance_methods = instance_methods(true).collect { |ea| ea.to_sym }
      attrs_to_be_memoized.concat(attrs - instance_methods)
      (attrs - attrs_to_be_memoized).each do |name|
        class_eval <<-RUBY
          alias_method :_#{name}, :#{name}
          def #{name}
            defined?(@#{name}) ? @#{name} : @#{name} = _#{name}()
          end
        RUBY
      end
    end

    def attrs_to_be_memoized
      @attrs_to_be_memoized ||= []
    end

    def method_added(method_name)
      if attrs_to_be_memoized.include?(method_name)
        attrs_to_be_memoized.delete(method_name)
        attr_memoized(method_name)
      end
      super
    end
  end
end
