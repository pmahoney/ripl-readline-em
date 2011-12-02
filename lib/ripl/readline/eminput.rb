module EventMachine
  # Convenience method to add a watch on `STDIN` and set
  # notify_readable to `true`.
  #
  # See EventMachine.watch
  def self.watch_stdin(handler, *args)
    conn = EventMachine.watch $stdin, handler, *args
    conn.notify_readable = true
    conn
  end
end

module Ripl
  module Readline
    module EmInput
      def initialize(opts = {})
        super()
        @on_exit = opts[:on_exit] || proc { EventMachine.stop_event_loop }
        handler_install
        Ripl.shell.before_loop
        trap('SIGINT') { handle_interrupt }
      end

      def notify_readable
        ::Readline.callback_read_char
      end

      def unbind
        super
        ::Readline.callback_handler_remove
        Ripl.shell.after_loop
        on_exit
      end

      def on_exit
        @on_exit.call if @on_exit
      end

      def receive_line(line)
        catch(:normal_exit) do
          catch(:ripl_exit) do
            throw :ripl_exit unless line # line = nil implies EOF

            Ripl.shell.input = line
            Ripl.shell.loop_once
            handler_install   # EditLine requires handler be
                              # reinstalled for each line.
                              # Seems harmless for Readline
            throw :normal_exit
          end
          detach              # :ripl_exit
        end
        # :normal_exit
      end

      def handle_interrupt
        ::Readline.callback_handler_remove
        puts
        handler_install
      end

      def handler_install
        ::Readline.callback_handler_install(Ripl.shell.prompt) do |line|
          EventMachine.next_tick { receive_line(line) }
        end
      end
    end
  end
end
