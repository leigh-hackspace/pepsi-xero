require 'pi_piper'
require 'xeroizer'
require 'logger'

include PiPiper

#setup connection
client = Xeroizer::PrivateApplication.new(ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'], ENV['PATH_TO_PRIVATE_KEY'])
logger = Logger.new File.new('pepsixero.log')

def send_to_xero(client)
  #get info about where to send the transaction and what to send
  contact = client.Contact.find('8ba5474b-fd18-4d0d-8a8c-cc5ad23ffeec') #gets the pepsi machine as a contact
  item = client.Item.find('27b832f8-f2db-407c-b654-2ab861052dba') #gets the line item that means one drinks can
  last_invoice_number = client.Invoice.all(:order => 'Date').last.invoice_number # get the last invoice in the system, we want to increment its invoice number  

  #start composing the invoice
  invoice = client.Invoice.build
  invoice.contact = contact
  invoice.type = 'ACCREC'
  invoice.date = Time.now
  invoice.due_date = Time.now
  invoice.status = 'AUTHORISED'
  invoice.invoice_number = "INV-"+(last_invoice_number.match(/\d+$/).to_s.to_i+1).to_s
  invoice.line_amount_types = 'Inclusive'
  invoice.add_line_item(:item_code => 'beverage_vend')
  invoice.save

  return invoice.invoice_number
end

after :pin => 23, :goes => :high do
  send_to_xero(client)
  logger.info "vend: 1 can time: #{Time.now} invoice: #{invoice.invoice_number}"
end

PiPiper.wait