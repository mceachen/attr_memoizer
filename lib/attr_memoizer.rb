require "attr_memoizer/version"

module AttrMemoizer
  def self.included(klass)
    klass.extend ClassMethods
  end

  module ClassMethods
    def attr_memoizer(*attrs)
      attrs_to_memoize.concat(attrs.collect { |ea| ea.to_sym }).uniq!
      # OMG 1.8.7 RETURNS STRINGS
      existing_methods = self.instance_methods(true).collect { |ea| ea.to_sym }
      (existing_methods & attrs_to_memoize).each do |name|
        attrs_to_memoize.delete(name)
        class_eval <<-RUBY
          alias_method :_#{name}, :#{name}
          def #{name}
            defined?(@#{name}) ? @#{name} : @#{name} = _#{name}()
          end
        RUBY
      end
    end

    def attrs_to_memoize
      @attrs_to_memoize ||= []
    end

    def method_added(method_name)
      attr_memoizer(method_name) if attrs_to_memoize.include?(method_name)
      super
    end
  end
end
