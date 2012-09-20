express = require 'express'

exports.start = () ->

  parser = require './parser'
  parser.parseSongList 'Urho Matti', (err, foo) ->
    console.log err
    console.log foo


  app = express()

  app.get '/', (req, res) ->
    res.send('Hello!')

  app.listen(process.env.PORT || 5000)
