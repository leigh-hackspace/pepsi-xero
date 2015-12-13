require 'pi_piper'
require 'xeroizer'

include PiPiper

#setup connection
def setup
	@client = Xeroizer::PrivateApplication.new(ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'], ENV['PATH_TO_PRIVATE_KEY'])
	send_to_xero
end

private

def send_to_xero
	#get info about where to send the transaction
	@contact = @client.Contact.find('8ba5474b-fd18-4d0d-8a8c-cc5ad23ffeec') #gets the pepsi machine as a contact
	@item = @client.Item.find('27b832f8-f2db-407c-b654-2ab861052dba') #gets the line item that means one drinks can
	
	#start composing the invoice
	@invoice = @client.Invoice.build
	@invoice.contact = @contact
	@invoice.type = 'ACCREC'
	@invoice.date = Time.now
	@invoice.due_date = Time.now
	@invoice.status = 'DRAFT'
	@invoice.invoice_number = 'INV-1013'
	@invoice.line_amount_types = 'Inclusive'
	@invoice.add_line_item(:item_code => 'beverage_vend')
	@invoice.save
end

after :pin => 23, :goes => :high do
  setup
end

PiPiper.wait