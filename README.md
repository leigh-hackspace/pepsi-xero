# Xero Pepsi Machine Hack

At Leigh Hackspace we were commissioned by the Manchester marketing agency BERT to hack a Pepsi drinks vending machine so that coin-operated vends would automagically be accounted in the cloud accounting system Xero www.xero.com . This all came about because of the generosity of Flow Online Accountancy, which is the accountant I use for my own businesses. When I mentioned to them I was starting a Hackspace in Leigh, they were very interested and offered to help out by providing free accountancy services and free access to the excellent Xero cloud accounting platform.

Shortly afterwards Flow became a major Xero partner organisation, and had some marketing funds to boost Xero's profile in the UK. The marketing agency wanted to show off the flexibilty of the Xero API so they asked us to do an Internet of Things kind of hack on a bit of vintage Pepsi vending machine. We used a Raspberry Pi for this although we could probably have done a similar job with an Arduino (although interfacing with the API might have been harder without a nice ruby gem to help, we would have probably had to send raw XML to the Xero API)

This repo contains the code that runs on the Raspberry Pi, accepting GPIO input on the RPi's GPIO pins and converting this to a REST API call to Xero.

An initial attempt was made to code this in PHP, but the creators of it were so ashamed of themselves they gave up and let us finish the job in a decent language.

# The Pepsi Machine
Despite being a UK 240V model for the refrigeration side of things, the Pepsi machine runs 120V for all it's internal workings, so one of our Electronics guys made a small board which steps down the voltage, smooths and rectifies it, and feeds it into an optocoupler to give us a safely isolated transistor output for the Raspberry Pi's GPIO input. This was fed from the Pi's own 3V3 supply and 0V ground, and a signal wire connected to GPIO pin 23, which inexplicably turns out to correspond to the physical pin marked 16 on the Custard Pi breakout board.

# The Raspberry Pi
We used a new Raspberry Pi Model B, with the Custard Pi 1A GPIO shield, running plain Raspbian. We used an Edimax WiFi dongle and the stock 2A power supply. After initial setup we fixed the Pi inside the Pepsi machine and used it headless via SSH.

# Raspberry Pi GPIO in Ruby
We used the pi_piper gem which gave us an event driven GPIO interface. It honestly took about 3 lines of code to get this bit working. Bravo pi_piper! Bravo Ruby!

# Xero and the Xeroizer Ruby gem
Xero has a comprehensive REST API so the interface was in theory easy, however, understanding how to represent a vending machine sale in Xero took some time, and then using the xeroizer ruby gem to send payloads to Xero took some work. In particular, the documentation for Xeroizer is weak in the area of creating an invoice and we had to experiment quite a bit in IRB to work out what Xeroizer was expecting as input in the various Invoice fields. In order to share what we learned I'll do a bit of documentation here. If I get time I'll submit it to Xeroizer for their Wiki too.

# Creating an invoice with Xeroizer
Having set up the connection to Xero with

`@client = Xeroizer::PrivateApplication.new(ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'], ENV['PATH_TO_PRIVATE_KEY'])` # we stored all the credentials in an env file which we `source`'d before running the Ruby file.
 
We start to build an invoice payload

`@invoice = @client.Invoice.build`

And we add elements to the invoice as necessary.

`@contact = @client.Contact.find('8ba5474b-fd18-4d0d-8a8c-cc5ad23ffeec')` #gets the pepsi machine as a Contact object using its contact_id, because @invoice.contact requires to be passed a Contact object

`@invoice.contact = @contact` # as mentioned above you need to supply a Contact object here
`@invoice.type = 'ACCREC'` # string input must match either 'ACCREC' (accounts receivable) or 'ACCPAY' (accounts payable)
`@invoice.date = Time.now` # both invoice.date and invoice.due_date expect a UTC DateTime. We weren't terribly bothered about the exact due_date on invoices for our hack so we just made the `due_date` the same as `date`.
`@invoice.due_date = Time.now`
`@invoice.status = 'DRAFT'` # string input, but it must match one of the list 'AUTHORIZED', 'DELETED', 'DRAFT', 'PAID', 'SUBMITTED', 'VOIDED' (see Xeroizer models in source code for details)
`@invoice.invoice_number = 'INV-1014'` # string which must be unique or you will get an API error.
`@invoice.line_amount_types = 'Inclusive'` # string which must match either 'Exclusive' or 'Inclusive'
`@invoice.add_line_item(:item_code => 'beverage_vend')` # this was the parameter that twisted my melon. Based on the behaviour of the #contact method above, I was expecting to have to pass an Item object in here. That doesn't work. Then I thought perhaps the contents of the Item object, expressed as a Hash. Nope. I could see from the Xero documentation that it was expecting LineItems to be an array of LineItem objects, but I could not work out how to create a Line Item object. I knew I wanted to use the sale Item I had already created in Xero via the GUI, and which I could access through the API, but couldn't seem to get Item into LineItem. I even tried directly instantiating a LineItem in Xeroizer, but again it didn't work. Weirdly, all it wants here is the item_code, and it will add the referenced Item as a LineItem. Phew. That bit took about 2 hours, I hope I can save you the trouble.
`@invoice.save` # and you're done.

Further information can be found in the Xeroizer github repo.