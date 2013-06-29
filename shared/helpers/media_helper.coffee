_ = require 'underscore'

THUMBNAIL_HEIGHT = 240

exports.getOriginal = (picture) -> _.find picture.get('media'), (medium) -> medium.original
exports.getThumbnail = (picture) -> _.min picture.get('media'), (medium) -> Math.abs(medium.height - THUMBNAIL_HEIGHT)