_ = require 'lodash'

charMap =
  'ä': 'a'
  'å': 'a'
  'ö': 'o'
  'ü': 'u'
  ' ': '-'
  '_': '-'
  '.': '-'

knownExtensions = [
  'jp2'
  'jpg'
  'png'
  'webp'
]


exports.slugify = (str) ->
  str = str.toLowerCase()
  str = _.map(str, (c) -> charMap[c] ? c).join('')
  str.replace(/[^a-z0-9-]/g, '').replace /-+/g, '-'

exports.makeBreadcrumb = (albumsOrPictures...) ->
  parent = _.first albumsOrPictures
  breadcrumb = parent.breadcrumb ? []

  for albumOrPicture in albumsOrPictures
    breadcrumb = breadcrumb.concat [
      path: albumOrPicture.path ? ''
      title: albumOrPicture.title ? ''
    ]

  breadcrumb

exports.removeExtension = (filename) ->
  filename.split('.', 1)[0]

exports.slugifyFilename = (filename) ->
  exports.slugify exports.removeExtension filename

exports.sanitizeFilename = (filename) ->
  return "" unless filename
  [filename, extension] = filename.split('.', 2)
  filename = exports.slugify filename
  extension = extension.toLowerCase()
  throw new Error "Spooky extension: #{extension}" unless extension in knownExtensions
  "#{filename}.#{extension}"

exports.stripLastComponent = (path) ->
  components = path.split('/')
  switch components.length
    when 1
      ''
    when 2
      '/'
    else
      left = components.length - 1
      components[...left].join('/')
