# AttrMemoized [![Build Status](https://travis-ci.org/mceachen/attr_memoized.png)](https://travis-ci.org/mceachen/attr_memoized)

The common ruby idiom for attribute [memoization](http://en.wikipedia.org/wiki/Memoization)
looks like this:

``` ruby
class Example
  def field
    @field ||= some_expensive_task()
  end
end
```

If ```some_expensive_task``` can return a "falsy" value (like ```nil``` or ```false```), this
doesn't work correctly—the prior memoized value of
```some_expensive_task``` will be ignored, and every subsequent call to ```field``` will result
in another call to ```some_expensive_task```.

<strong>AttrMemoized aims to usurp your misbegotten love of ```||=```.</strong>

## Usage

1. ```include AttrMemoized```
2. Call ```attr_memoized``` with the attributes you want memoized
3. Throw your ```@something ||=``` **on the [ground](http://en.wikipedia.org/wiki/Threw_It_on_the_Ground)**.

``` ruby
class Example
  include AttrMemoized
  attr_memoized :field, :another_field

  def field
    # code that computes field
  end

  def another_field
    # code that computes another_field
  end
end
```

Calling ```Example.new.field``` will call your definition of ```field```, memoize the result
for subsequent calls to an ivar called ```@field```, and return that value.

Note that caching method results does **not** span instances.

### Gotcha

To keep the metaprogramming demons at bay, we're using ```alias_method``` to rename the method—if
you rename the attribute or look for consumers of the attribute, you at least has a chance of
finding the attribute and their consumers, as opposed to how deferred_attribute worked, which made
you call a method that only existed after the attr_memoized method ran.

The problem with using ```alias_method``` at the time that ```attr_memoized``` is called, is that
the method may not be defined in the class yet. To get around this issue, we implement the
class-level ```method_added``` hook, and set up the memoization after the method is defined.

If you are also using ```method_added```, remember to call ```super``` at the end of your
implementation. See the test cases for examples, and proof that this nonsense all works.

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'attr_memoized'
```

And then execute:

    $ bundle

## Changelog

### 0.0.7

* Renamed from [deferred_attribute](https://github.com/mceachen/deferred_attribute)
