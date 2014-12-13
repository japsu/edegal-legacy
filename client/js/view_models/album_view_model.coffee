ko = require 'knockout'
require 'knockout-mapping'

module.exports = class AlbumViewModel
  constructor: ->
    @album = ko.mapping.fromJS {}

  setAlbum: (album) ->
    ko.mapping.fromJS album, {}, @album
