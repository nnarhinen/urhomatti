request = require 'request'
jquery = require 'jquery'

exports.parseSongList = (title, callback) ->
  request({url: "http://wiki.digit.fi/#{encodeURIComponent(title)}"}, (err, res, body) ->
    error = err
    if !error && res.statusCode != 200
      error = res.statusCode
    if error
      callback(error, null)

    article = jquery(body)
    ret = {}
    ret.title = article.find("#firstHeading").text()
    ret.songs = []
    article.find('a[title*="UrhoMatti:"]').each (index, link) ->
      songNumberParts = jquery(link).parent().text().split('.')
      firstPart = songNumberParts[0]
      songNumber = -1
      if !isNaN(parseInt(firstPart))
        songNumber = parseInt(firstPart)

      categoryNode = jquery(link).closest('ul').prev()

      ret.songs.push
        title: jquery(link).attr('title')
        link: jquery(link).attr('href')
        songNumber: songNumber
        category: categoryNode.text()
    callback(false, ret)
  )
