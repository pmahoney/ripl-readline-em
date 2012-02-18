# This example uses readline directly without going through ripl.  This is not
# the primary goal of this library, but a useful side effect of extending the
# Readline api.

require 'readline/callback.rb'
require 'eventmachine'

module Handler
  def initialize
    Readline::callback_handler_install('> ') do |line|
      if line =~ /(quit|exit)/
        EventMachine::stop_event_loop
      else
        puts "have a line: #{line}"
      end
    end
  end

  def notify_readable
    Readline.callback_read_char
  end

  def unbind
    Readline.callback_handler_remove
  end
end

EventMachine.run do
  EventMachine.add_periodic_timer(2) do
    # Example of writing output while line is being edited.
    #
    # See also http://stackoverflow.com/questions/1512028/gnu-readline-how-do-clear-the-input-line
    print "\b \b" * Readline.line_buffer.size
    print "\r"
    begin
      puts "#{Time.now}"
    ensure
      Readline.forced_update_display
    end
  end

  conn = EventMachine.watch $stdin, Handler
  conn.notify_readable = true
end
