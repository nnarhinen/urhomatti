express = require 'express'

halify = (song) ->
  song.links =
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

  app.get '/', (req, res) ->
    ret= {}
    ret.message = "Hello, Urho Matti"
    ret._embedded =
      songs: songs
    res.send ret
    

  app.listen(process.env.PORT || 5000)
