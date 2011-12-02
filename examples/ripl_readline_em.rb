require 'eventmachine'
require 'ripl/readline/em'

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

  # Start up Ripl, but it will not receive any user input
  Ripl.start

  # Watch stdin for input, sending it to Ripl as entered (including editing,
  # history and completion).
  #
  # Default behavior is to call EventMachine.stop_event_loop when the shell is
  # exited.  Modify this behavior by passing a hash with an `:on_exit` entry,
  # either nil or a Proc that will be run on exit instead of the default.
  EventMachine.watch_stdin Ripl::Readline::EmInput

  # -or-
  # EventMachine.watch_stdin Ripl::Readline::EmInput, :on_exit => nil

  # Yet another option is to create your own handler module, include
  # Ripl::Readline::EmInput, and override the `on_exit` method.
end
