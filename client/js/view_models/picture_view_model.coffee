ko = require 'knockout'
require 'knockout-mapping'

module.exports = class PictureViewModel
  constructor: ->
    @picture = ko.mapping.fromJS {}
