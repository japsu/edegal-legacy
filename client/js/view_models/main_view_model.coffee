page = require 'page'
ko = require 'knockout'

AlbumViewModel = require './album_view_model.coffee'
PictureViewModel = require './picture_view_model.coffee'
i18nHelper = require '../helpers/i18n_helper.coffee'
albumService = require '../services/album_service.coffee'
pathHelper = require '../../../shared/helpers/path_helper.coffee'
packageJson = require '../../../package.json'

module.exports = class MainViewModel
  constructor: ->
    @albumViewModel = new AlbumViewModel
    @pictureViewModel = new PictureViewModel
    @breadcrumb = ko.observable null
    @activeView = ko.observable null
    @copyrightFooter = @i("Edegal copyright footer").replace('VERSION', packageJson.version)

    page /^([\/a-zA-Z0-9-\/]*)$/, (ctx, next) =>
      albumService.getContent(ctx.params[0]).then ({album, picture}) =>
        @breadcrumb pathHelper.makeBreadcrumb album

        if picture
          @pictureViewModel.setPicture picture
          @activeView 'picture'
        else
          @albumViewModel.setAlbum album
          @activeView 'album'

        document.title =
          if album.path == '/'
            album.title
          else
            "#{album.title} – #{album.breadcrumb[0].title}"

  i: (key) -> i18nHelper.translate key
