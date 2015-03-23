stout = require 'stout'

app = new stout.App '//example.com'

app.routes =

  '/sayhello/:name', (name) ->
    # Echo hello to the browser window

  '/', ->
    # homepage view thingy
