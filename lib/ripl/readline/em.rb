require 'eventmachine'
require 'readline/callback'
require 'ripl'
require 'ripl/readline'
require 'ripl/readline/eminput'
require 'ripl/readline/em/version'

module Ripl
  module Readline
    module Em
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
