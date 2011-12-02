require 'readline/callback.rb'

Readline::callback_handler_install('> ') do |line|
  puts "have a line: #{line}"
end

begin
  loop do
    select [$stdin]
    Readline::callback_read_char
  end
ensure
  Readline::callback_handler_remove
end
