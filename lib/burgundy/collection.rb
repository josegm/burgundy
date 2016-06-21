module Burgundy
  class Collection < SimpleDelegator
    include Enumerable

    def initialize(items, wrapping_class = nil, *args)
      @items = items
      @wrapping_class = wrapping_class
      @args = args
      __setobj__(@items)
    end

    def each(&block)
      to_ary.each(&block)
    end

    def infer_wrap(item, *args)
      inferred_wrap_class = infer_wrap_class(item)
      if class_exists?(inferred_wrap_class)
        inferred_wrap_class.new(item, *args)
      else
        item
      end
    end

    def infer_wrap_class(item)
      class_name = "#{item.class.name}Presenter"
      Object.const_get(class_name)
    end

    def class_exists?(klass)
      return klass.is_a?(Class)
    rescue NameError
      return false
    end

    def to_ary
      @cache ||=  if @wrapping_class
                    @items.map {|item| @wrapping_class.new(item, *@args) }
                  else
                    if @items.respond_to?(:map)
                      @items.map {|item| infer_wrap(item, *@args) }
                    else
                      @items.to_a
                    end
                  end
    end
    alias_method :to_a, :to_ary
  end
end
