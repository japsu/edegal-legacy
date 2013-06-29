_ = require 'underscore'

originalSlugify = require 'slug'
originalSlugify.charmap['.'] = '-'
originalSlugify.charmap['_'] = '-'

exports.slugify = (str) -> originalSlugify(str).toLowerCase().replace(/[^a-z0-9-]/g, '')

exports.makeBreadcrumb = (albumsOrPictures...) ->
  parent = _.first albumsOrPictures
  breadcrumb = parent.breadcrumb ? parent.get?('breadcrumb')

  for albumOrPicture in albumsOrPictures
    breadcrumb = breadcrumb.concat [
      path: albumOrPicture.path ? albumOrPicture.get?('path') ? ''
      title: albumOrPicture.title ? albumOrPicture.get?('title') ? ''
    ]

  breadcrumb