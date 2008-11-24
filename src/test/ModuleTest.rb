# Tests for methods in Kernel.rb
require File.expand_path('simple', File.dirname(__FILE__))

# Test that assignment to a constant sets the class name correctly
Foo = Class.new
test(Foo.class, Class, 'Foo.class == Class')

test(Math.constants.include?("PI"), true, 'Math::PI')
test(Math.constants.include?("E"), true,  'Math::E')
test(Math.constants.length,           2,  'Math.constants.length')

# Test const_defined?, const_get and const_set
module M
end

test(M.constants.length,         0, 'M.constants 1')
test(M.const_defined?(:FOO), false, 'const_defined? A')

M.const_set(:FOO, 12)

test(M.constants.length,        1, 'const_set A')
test(M.constants.length,        1, 'const_set B')
test(M.const_get(:FOO),        12, 'const_get C')
test(M.const_defined?(:FOO), true, 'const_defined? B')
test(M.constants,         ['FOO'], 'constants 2')


# Test removing constants
#
# Right now, we don't have module_eval working, so instead of this:
#    M.module_eval { remove_const(:FOO) }
# we'll do it all in a class

class C
  def self.remove_my_const(sym)
    remove_const(sym)
  end
end

test(C.constants.length,         0, 'remove_const A')
test(C.const_defined?(:FOO), false, 'remove_const B')

C.const_set(:FOO, 55)

test(C.constants.length,         1, 'remove_const C')
test(C.const_defined?(:FOO),  true, 'remove_const D')

C.remove_my_const(:FOO)

test(C.constants.length,         0, 'remove_const E')
test(C.const_defined?(:FOO), false, 'remove_const F')

report
Gemstone.abortTransaction if defined? RUBY_ENGINE
true

