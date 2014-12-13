ko = require 'knockout'
require 'knockout-mapping'

module.exports = class AlbumViewModel
  constructor: ->
    @album = ko.mapping.fromJS {}

  setAlbum: (album) ->
    console?.log 'AlbumViewModel', 'setAlbum', album
    ko.mapping.fromJS album, {}, @album
