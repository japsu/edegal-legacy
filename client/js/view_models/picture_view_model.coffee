ko = require 'knockout'
require 'knockout-mapping'

mediaHelper = require '../helpers/media_helper.coffee'

module.exports = class PictureViewModel
  constructor: ->
    @picture = ko.mapping.fromJS {}
    @medium = ko.mapping.fromJS {}

  setPicture: (picture) ->
    ko.mapping.fromJS picture, {}, @picture

    medium = mediaHelper.selectMedia picture
    ko.mapping.fromJS medium, {}, @medium
