require 'pi_piper'
require 'xero_gateway'

include PiPiper

gateway = XeroGateway::Gateway.new(YOUR_OAUTH_CONSUMER_KEY, YOUR_OAUTH_CONSUMER_SECRET)

after :pin => 23, :goes => :high do
  puts "can vended"
end

PiPiper.wait