express = require 'express'

halify = (song) ->
  song._links =
    self:
      href: "/songs/#{song.title}"
  return song


exports.start = () ->
  songs = []
  parser = require './parser'
  parser.parseSongList 'Urho Matti', (err, list) ->
    song = list.songs.shift()
    callback = (er, so) ->
      if so
        so.category = song.category
        so.song_number = song.songNumber
        songs.push halify(so)
        song = list.songs.shift()
        if song
          parser.parseSong song.title, callback

    parser.parseSong song.title, callback


  app = express()

  app.use(express.static("#{__dirname}/../public"))

  app.get '/', (req, res) ->
    ret= {}
    ret.message = "Hello, Urho Matti"
    ret._embedded =
      songs: songs
    ret._links =
      self:
        href: "/"
    res.send ret
  app.get '/songs/:song', (req, res) ->
    song = (songs.filter (s) -> s.title == req.params['song'])[0]
    if song
      res.send song
    else
      res.send 404

  app.listen(process.env.PORT || 5000)
