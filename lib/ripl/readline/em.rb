require 'eventmachine'
require 'readline/callback'
require 'ripl'
require 'ripl/readline'

module Ripl
  module Readline
    module Em
      module InputHandler
        def notify_readable
          ::Readline.callback_read_char
        end

        def unbind
          ::Readline.callback_handler_remove
        end
      end
    end
  end
end

module Ripl
  module Readline
    module Em
      VERSION = '0.1.0'

      def get_input
        history << @input
        @input
      end

      def redisplay
        ::Readline.set_prompt(Ripl.shell.prompt)
        ::Readline.refresh_line
      end

      def handle_line(line)
        catch(:normal_exit) do
          catch(:ripl_exit) do
            throw :ripl_exit unless line # line = nil implies EOF

            Ripl.shell.input = line
            Ripl.shell.loop_once
            redisplay
            throw :normal_exit
          end

          # If we got here, it means :ripl_exit was caught
          ::Readline.callback_handler_remove
          after_loop
        end
      end

      def loop_override
        before_loop

        ::Readline.callback_handler_install do |line|
          EventMachine.next_tick { handle_line(line) }
        end

        # is hardcoded $stdin always appropriate?
        conn = EventMachine.watch $stdin, InputHandler
        conn.notify_readable = true
        
        redisplay
      end

      def before_loop
        super
        trap('SIGINT') { handle_interrupt }
      end

      def after_loop
        super
        EventMachine.stop_event_loop
      end

      def handle_interrupt
        super
        redisplay
      end
    end
  end
end

Ripl::Shell.include Ripl::Readline::Em
class Ripl::Shell
  def loop
    loop_override
  end
end
