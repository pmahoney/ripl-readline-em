require 'eventmachine'
require 'readline/callback'
require 'ripl'
require 'ripl/readline'
require 'ripl/readline/eminput'

module Ripl
  module Readline
    module Em
      VERSION = '0.2.0'

      def get_input
        history << @input
        @input
      end

      def async_loop
        # no-op; functionality is done asynchronously
      end
    end
  end
end

Ripl::Shell.include Ripl::Readline::Em

class Ripl::Shell
  def loop
    async_loop
  end
end
