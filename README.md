Xero Pepsi Machine Hack
-----------------------

# Purpose

# How it/will works
This project will be split into two parts:
* RaspberryPi GPIO Listener
* API2Xero

## RaspberryPi GPIO Listener
Hooks into the Pepsi Machine and wait for a purchase to be made.
When a purcahse is made, it will post a very simple request to the API2Xero Application

## API2Xero
When this recieves a request from the RaspberryPi specifying that a purchase has been made.
This API will log it into a simple SQLite database and pass it through to Xero as a Sale.
