ko = require 'knockout'
require 'knockout-mapping'

mediaHelper = require '../helpers/media_helper.coffee'
theOtherMediaHelper = require '../../../shared/helpers/media_helper.coffee'

module.exports = class PictureViewModel
  constructor: ->
    @picture = ko.mapping.fromJS {}
    @medium = ko.mapping.fromJS {}
    @original = ko.mapping.fromJS {}

  setPicture: (picture) ->
    ko.mapping.fromJS picture, {}, @picture

    medium = mediaHelper.selectMedia picture
    ko.mapping.fromJS medium, {}, @medium

    original = theOtherMediaHelper.getOriginal picture
    ko.mapping.fromJS original, {}, @original
