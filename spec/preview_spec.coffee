should = require 'should'
sinon  = require 'sinon'
Q      = require 'q'
_      = require 'underscore'

require './helpers/spec_helper'
require './helpers/db_helper'

{getAlbum, newAlbum} = require '../server/services/album_service'
previewService = require '../server/services/preview_service'

album =
  path: '/'
  title: 'Root'
  pictures: [
    path: '/foo'
    title: 'Foo'
    media: [
      src: '/pictures/foo.jp2'
      width: 1600
      height: 1200
      original: true
    ]
  ,
    path: '/bar'
    title: 'Bar'
    media: [
      src: '/pictures/bar.jp2'
      width: 1600
      height: 1200
      original: true
    ]
  ]

describe 'Preview service', ->
  beforeEach (done) ->
    sinon.stub(previewService, 'makeDirectories').returns Q.when null
    sinon.stub(previewService, 'resizeImage').returns Q.when [width: 640, height: 640]

    newAlbum(null, album).then ->
      done()
    .done()

  afterEach ->
    previewService.makeDirectories.restore()
    previewService.resizeImage.restore()

  describe 'createPreview', ->
    it 'should create a preview for a photo', (success) ->
      getAlbum('/').then (album) ->
        picture = _.first album.pictures

        previewService.createPreview
          picture: picture
          size:
            width: 640
            height: 480
            quality: 90
      .then (result) ->
        should.deepEqual result,
          result: 'created'
          success: true

        getAlbum('/')
      .then (album) ->
        picture = _.first album.pictures
        picture.media.length.should.equal 2

        _.find(picture.media, (media) -> media.width == 640 and not media.original).should.exist
        _.find(picture.media, (media) -> media.width == 1600 and media.original).should.exist

        success()
      .done()

  describe 'createPreviews', ->
    it 'should create previews for an album', (success) ->
      getAlbum('/').then (album) ->
        previewService.createPreviews(album)
      .then ->
        getAlbum('/')
      .then (album) ->
        album.pictures.forEach (picture) ->
          picture.media.length.should.equal 2

          _.find(picture.media, (media) -> media.width == 640 and not media.original).should.exist
          _.find(picture.media, (media) -> media.width == 1600 and media.original).should.exist     

        success()
      .done()
