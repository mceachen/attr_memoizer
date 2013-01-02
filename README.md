# AttrMemoizer [![Build Status](https://api.travis-ci.org/mceachen/attr_memoizer.png?branch=master)](https://travis-ci.org/mceachen/attr_memoizer)

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

<strong>AttrMemoizer aims to usurp your misbegotten love of ```||=```.</strong>

## Usage

1. ```include AttrMemoizer```
2. Call ```attr_memoizer``` with the attributes you want memoized
3. Throw your ```@something ||=``` **on the [ground](http://en.wikipedia.org/wiki/Threw_It_on_the_Ground)**.

``` ruby
class Example
  include AttrMemoizer
  attr_memoizer :field, :another_field

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

Note that caching method results does **not** span instances:

``` ruby
class TimeHolder
  include AttrMemoizer
  attr_memoizer :a_time

  def a_time
    Time.now
  end
end

t = TimeHolder.new
t.a_time
#> 2013-01-01 00:00:00 -0800
sleep 1
t.a_time
#> 2013-01-01 00:00:00 -0800 # < this is the memoized value

# But with a new instance, we get a new value:
TimeHolder.new.a_time
#> 2013-01-01 20:26:41 -0800
```

### Gotcha

To keep the metaprogramming demons at bay, we're using ```alias_method``` to rename the method—if
you rename the attribute or look for consumers of the attribute, you at least has a chance of
finding the attribute and their consumers, as opposed to how deferred_attribute worked, which made
you call a method that only existed after the attr_memoizer method ran.

The problem with using ```alias_method``` at the time that ```attr_memoizer``` is called, is that
the method may not be defined in the class yet. To get around this issue, we implement the
class-level ```method_added``` hook, and set up the memoization after the method is defined.

If you are also using ```method_added```, remember to call ```super``` at the end of your
implementation. See the test cases for examples, and proof that this nonsense all works.

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'attr_memoizer'
```

And then execute:

    $ bundle

## Changelog

### 0.0.1

* There were previous names for this library. We won't speak of them again.