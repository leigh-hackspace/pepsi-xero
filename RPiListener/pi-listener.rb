require 'pi_piper'
include PiPiper

after :pin => 23, :goes => :high do
  puts "can vended"
end

PiPiper.wait