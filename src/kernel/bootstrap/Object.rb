# Random is the Smalltalk class Random
Random.class_primitive_nobridge 'new'
Random.primitive_nobridge 'next', 'nextInt:'
Random.primitive_nobridge 'next'
RandomInstance = Random.new

class Object
  include Kernel

    # Begin private helper methods

    # primitive_nobridge has max of 3 normal args, 1 star arg, 1 block arg
    #  example with a block argument
    #    primitive_nobridge '_foo*&' , '_foo:a:b:c:d:e:'
    #  example without a block argument
    #    primitive_nobridge '_foo*' , '_foo:a:b:c:d:'

    #  begin special sends
    #    these are optimized by the code generator to be special bytecodes
    #
    #    entries here are so that perform will work.
    # _isInteger allows integer?  special sends to non-Numeric objects
    primitive_nobridge '_isInteger', '_isInteger'
    #
    primitive_nobridge '_isFixnum', '_isSmallInteger'
    primitive_nobridge '_isFloat', '_isFloat'
    primitive_nobridge '_isNumber', '_isNumber'
    primitive_nobridge '_isSymbol', '_isSymbol'
    primitive_nobridge '_isBlock', '_isExecBlock'
    primitive_nobridge '_isArray', '_isArray'
    primitive_nobridge '_isHash', '_isRubyHash'
    primitive_nobridge '_isString', '_isOneByteString'
    primitive_nobridge '_isRegexp', '_isRegexp'
    primitive_nobridge '_isRange', '_isRange'
    # end special sends

    #  following are installed by RubyContext>>installPrimitiveBootstrap
    #    primitive_nobridge 'class', 'class' # installed in Object
    #  end installPrimitiveBootstrap

    #  private method _each: contains on:do: handler for RubyBreakException ,
    #  all env1 sends of each& are compiled as sends of _each&
    primitive_nobridge '_each&', '_rubyEach:'

    # End private helper methods

    primitive_nobridge '==', '='
    primitive 'halt'
    primitive 'hash'
    primitive 'object_id', 'asOop'
    primitive '__id__' , 'asOop'

    #  not   is now a special selector,
    #   GsComSelectorLeaf>>selector:  translates #not to bytecode Bc_rubyNOT
    # primitive 'not'

    primitive 'nil?' , '_rubyNilQ'

    # rubySend: methods implemented in .mcz
    primitive_nobridge 'send',  'rubySend:'
    primitive_nobridge 'send',  'rubySend:with:'
    primitive_nobridge 'send',  'rubySend:with:with:'
    primitive_nobridge 'send',  'rubySend:with:with:with:'
    primitive_nobridge 'send&', 'rubySend:block:'
    primitive_nobridge 'send&', 'rubySend:with:block:'
    primitive_nobridge 'send&', 'rubySend:with:with:block:'
    primitive_nobridge 'send&', 'rubySend:with:with:with:block:'
    primitive          'send*&' , 'rubySend:withArgs:block:'

    #  __send__ defined per MRI, non-overrideable version of send
    #  TODO: disallow redef in Object after prims loaded
    primitive_nobridge '__send__',  'rubySend:'
    primitive_nobridge '__send__',  'rubySend:with:'
    primitive_nobridge '__send__',  'rubySend:with:with:'
    primitive_nobridge '__send__',  'rubySend:with:with:with:'
    primitive_nobridge '__send__&', 'rubySend:block:'
    primitive_nobridge '__send__&', 'rubySend:with:block:'
    primitive_nobridge '__send__&', 'rubySend:with:with:block:'
    primitive_nobridge '__send__&', 'rubySend:with:with:with:block:'
    primitive          '__send__*&' , 'rubySend:withArgs:block:'

    primitive 'dup', '_basicCopy'

    primitive 'freeze', 'immediateInvariant'
    primitive 'frozen?', 'isInvariant'

    primitive_nobridge 'respond_to?', 'rubyRespondsTo:'

    # install this prim so  anObj.send(:kind_of?, aCls)   will work
    primitive_nobridge 'kind_of?' , '_rubyKindOf:'

    # install this prim so  anObj.send(:is_a?, aCls)   will work
    primitive_nobridge 'is_a?' , '_rubyKindOf:'

    def respond_to?(aSymbol, includePrivateBoolean)
      # Gemstone: the argument includePrivateBoolean is ignored
      respond_to?(aSymbol)
    end

    primitive 'print_line', 'rubyPrint:'

    # pause is not standard Ruby, for debugging only .
    #  trappable only by an Exception specifying exactly error 6001
    primitive 'pause', 'pause'

    #                                   rubyInspect comes from .mcz
    primitive_nobridge '_inspect', '_rubyInspect:'

    def inspect(touchedSet=nil)
      self._inspect(touchedSet)
    end

    primitive_nobridge '_instVarAt', 'rubyInstvarAt:'
    primitive_nobridge '_instVarAtPut', 'rubyInstvarAt:put:'
    primitive_nobridge '_instVarNames', 'rubyInstvarNames'

    def instance_variable_get(aName)
      aName = Type.coerce_to(aName, String, :to_str)
      unless (aName[0].equal?( ?@ ))
        return nil
      end
      _instVarAt(aName[1, aName.length].to_sym)
    end

    def instance_variable_set(aName, aVal)
      aName = Type.coerce_to(aName, String, :to_str)
      unless (aName[0].equal?( ?@ ))
        return nil
      end
      _instVarAtPut(aName[1, aName.length].to_sym, aVal)
      aVal
    end

    def instance_variables
      syms = self._instVarNames
      len = syms.length
      res = Array.new(len)
      n = 0
      while (n < len)
        res[n] = '@' << syms[n]
        n = n + 1
      end
      res
    end

    primitive 'method', 'rubyMethod:'

    def ===(obj)
        self == obj
    end

    def at_exit
    end

    # block_given?  is implemented by the ruby compiler .
    #   do not code any definition of block_given? here .
    # Attempts to reimplement  block_given?  will fail with a compiler error.

    def initialize(*args)
       self
    end

    def eql?(other)
      self == other
    end

    def eval(str)
        RUBY.module_eval(str, Object)
    end

  def extend(*modules)
    if (modules.length > 0)
      cl = class << self
        self
      end
      modules.each{ |aModule| cl.include(aModule) }
    end
  end

  def flatten_onto(output)
    output << self
    output
  end

    def loop
        raise LocalJumpError, "no block given" unless block_given?

        while true
            yield
        end
    end

    def pretty_inspect
      inspect;
    end

    def raise(err, str)
        err.signal(str)
    end

    def raise(err)
        err.signal(nil)
    end

    def raise
        RuntimeError.signal(nil)
    end

    def rand(n=nil)
        if n
            RandomInstance.next(n)
        else
            RandomInstance.next
        end
    end

    def to_a
       # remove this method for MRI 1.9 compatibility
       [ self ]
    end

    def to_fmt
      to_s
    end

    def to_s
      self.class.name.to_s
    end

    # Object should NOT have a to_str.  If to_str is implementd by passing
    # to to_s, then by default all objects can convert to a string!  But we
    # want classes to make an effort in order to convert their objects to
    # strings.
    #
    # def to_str
    #   to_s
    # end

    # BEGIN RUBINIUS
    def instance_of?(cls)
      # TODO: Object#instance_of?: Uncomment parameter checks when (A)
      # Module is installed in the globals dict and class comparison is
      # working properly.
#       if cls.class != Class and cls.class != Module
#         # We can obviously compare against Modules but result is always false
#         raise TypeError, "instance_of? requires a Class argument"
#       end

      self.class.equal?(cls)
    end
    # END RUBINIUS

end
