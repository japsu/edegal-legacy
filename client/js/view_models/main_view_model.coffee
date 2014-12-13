page = require 'page'

AlbumViewModel = require './album_view_model.coffee'
PictureViewModel = require './picture_view_model.coffee'
i18nHelper = require '../helpers/i18n_helper.coffee'
albumService = require '../services/album_service.coffee'
pathHelper = require '../../../shared/helpers/path_helper.coffee'

module.exports = class MainViewModel
  constructor: ->
    @albumViewModel = new AlbumViewModel
    @pictureViewModel = new PictureViewModel
    @breadcrumb = ko.observable null
    @activeView = ko.observable null

    page /^([\/a-zA-Z0-9-\/]*)$/, (ctx, next) =>
      albumService.getContent(ctx.params[0]).then ({album, picture}) =>
        @breadcrumb pathHelper.makeBreadcrumb album

        if picture
          @pictureViewModel.setPicture picture
          @activeView 'picture'
        else
          @albumViewModel.setAlbum album
          @activeView 'album'

  i: (key) -> i18nHelper.translate key
