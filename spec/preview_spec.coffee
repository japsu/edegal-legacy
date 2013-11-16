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
  ]

describe 'Preview service', ->
  beforeEach (done) ->
    sinon.stub(previewService, 'makeDirectories')
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
        success()
      .done()
