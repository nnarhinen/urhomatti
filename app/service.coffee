express = require 'express'
cradle = require 'cradle'
con = new (cradle.Connection)(process.env.CLOUDANT_URL || "http://127.0.0.1:5984")
db = con.database 'urhomatti'

halify = (song) ->
  song._links =
    self:
      href: "/songs/#{song._id}"
  delete song.type
  delete song._id
  delete song._rev
  return song


exports.start = () ->
  parse = () ->
    parser = require './parser'
    parser.parseSongList 'Urho Matti', (err, list) ->
      song = list.songs.shift()
      callback = (er, so) ->
        if so
          so.category = song.category
          so.song_number = song.songNumber
          so.type = 'song'
          db.view 'urhomatti/songs_by_title', { key: so.title }, (err, queryResult) ->
            if queryResult.length > 0
              existing = queryResult[0].value
              db.save existing._id, existing._rev, so, (err, res) ->
                if (err)
                  console.log 'error', err
            else
              db.save so, (err, res) ->
                if (err)
                  console.log 'error', err
          song = list.songs.shift()
          if song
            parser.parseSong song.title, callback

      parser.parseSong song.title, callback

  db.exists (err, exists) ->
    if (err)
      console.log('error', err)
    else if exists
      parse()
    else
      db.create (err, res) ->
        if (err)
          console.log err
          return
        db.save '_design/urhomatti',
          views:
            songs:
              map: '(function (doc) { if (doc.type && doc.type == "song") { emit(doc.song_number, doc); } })'
            songs_by_title:
              map: '(function (doc) { if (doc.type && doc.type == "song") { emit(doc.title, doc); } })'
          , (err, res) ->
            if (err)
              console.log err
              return
            parse()


  app = express()

  app.use(express.static("#{__dirname}/../public"))

  app.get '/', (req, res) ->
    songs = []
    db.view 'urhomatti/songs', (err, result) ->
      if (err)
        res.send(500, err)
        return
      for song in result
        songs.push(halify(song.value))
      ret= {}
      ret.message = "Hello, Urho Matti"
      ret._embedded =
        songs: songs
      ret._links =
        self:
          href: "/"
      res.send ret
  app.get '/songs/:song', (req, res) ->
    db.get req.params.song, (err, doc) ->
      if doc && doc.type == "song"
        res.send(halify(doc))
      else
        res.send 404

  app.listen(process.env.PORT || 5000)
