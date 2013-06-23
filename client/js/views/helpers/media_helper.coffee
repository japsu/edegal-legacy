$ = require 'jquery'

{getContent} = require '../../models/helpers/content_helper.coffee'

selectMedia = (picture) ->
  # XXX better selectMedia
  _.first picture.get('media')

preloadMedia = (selector, path) ->
  getContent(path).then (content) ->
    {album, picture} = content
    selectedMedia = selectMedia picture
    return unless selectedMedia and selectedMedia.src
    $('<img/>').attr 'src', selectedMedia.src
  .done()

module.exports = {selectMedia, preloadMedia}
window.edegalViewHelperMedia = module.exports if window?