ko = require 'knockout'


module.exports = class AlbumViewModel
  constructor: ->
    @album = ko.observable null

  setAlbum: (album) ->
    @album album
