require 'ffi'
require 'readline'

module Readline
  # An alternate, callback-based interface to Readline for use in a
  # larger event loop.
  #
  # Used FFI for access to the Readline C library.  The Readline
  # module (Ruby core) is extended with this module.
  #
  # See http://cnswww.cns.cwru.edu/php/chet/readline/readline.html#SEC41
  module Callback
    extend FFI::Library

    def self.editline?
      @__is_editline__ ||= (Readline::VERSION rescue nil).to_s[/editline/i]
    end

    if editline?
      ffi_lib 'edit'
    else
      ffi_lib 'readline'
    end

    callback :rl_vcpfunc_t, [:string], :void
    attach_function :rl_callback_handler_install, [:string, :rl_vcpfunc_t], :void
    attach_function :rl_callback_read_char, [], :void
    attach_function :rl_callback_handler_remove, [], :void

    # as-is functions
    attach_function :forced_update_display, :rl_forced_update_display, [], :void

    if editline?
      def set_prompt(*args)
        # noop; rl_set_prompt isn't exported by EditLine
      end
    else
      attach_function :set_prompt, :rl_set_prompt, [:string], :int
    end

    # Set up the terminal for readline I/O and display the initial
    # expanded value of prompt. Save the value of `block` to call when a
    # complete line of input has been entered.
    #
    # A reference to the handler is saved in an instance variable so
    # that it will not be garbage collected.  Subsequent calls to
    # #handler_install will displace this reference.  A call to
    # #handler_remove will remove the reference.
    #
    # @param [String] prompt
    #
    # @yield [String] a handler taking the text of the line as the sole
    # argument, called when a complete line of input has been entered.
    def callback_handler_install(prompt = nil, &block)
      raise ArgumentError, 'block is required' unless block
      @rl_callback_handler = block
      rl_callback_handler_install(prompt, block)
    end

    # When keyboard input is available (determined by, e.g. calling
    # select on $stdin), this method should be called.  If that
    # character completes the line, the block registered by
    # #callback_handler_install will be called.  Before calling the
    # handler function, the terminal settings are reset to the values
    # they had before calling #callback_handler_install. If the
    # handler function returns, the terminal settings are modified for
    # Readline's use again. EOF is indicated by calling handler with a
    # NULL line.
    def callback_read_char
      rl_callback_read_char
    end

    # Restore the terminal to its initial state and remove the line
    # handler. This may be called from within a callback as well as
    # independently. If the handler installed by #handler_install does
    # not exit the program, either this function or the function
    # referred to by the value of rl_deprep_term_function (not sure what
    # that translates to in Ruby) should be called before the program
    # exits to reset the terminal settings.
    def callback_handler_remove
      rl_callback_handler_remove
      @rl_callback_handler = nil
    end
  end
end

module Readline
  extend Callback
end
