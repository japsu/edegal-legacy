should = require 'should'
sinon = require 'sinon'
proxyquire = require 'proxyquire'

clientMediaHelper = require '../client/js/helpers/media_helper.coffee'
sharedMediaHelper = require '../shared/helpers/media_helper.coffee'

picture =
  path: '/selectMedia/picture'
  media: [
    {
      width: 120
      height: 80
      src: 'http://example.com/chibi.jpg'
    }
    {
      width: 320
      height: 240
      src: 'http://example.com/320x240.jpg'
    }
    {
      width: 800
      height: 600
      src: 'http://example.com/800x600.jpg'
    }
    {
      width: 1600
      height: 1200
      src: 'http://example.com/1600x1200.jpg'
    }
    {
      width: 640
      height: 480
      src: 'http://example.com/640x480.jpg'
    }
  ]

pictureWithTooLargeMedia =
  path: '/selectMedia/picture-with-too-large-media'
  media: [
    {
      width: 2048
      height: 1536
      src: 'http://example.com/2048x1536.jpg'
      original: true
    }
    {
      width: 1600
      height: 1200
      src: 'http://example.com/1600x1200.jpg'
    }
  ]

describe 'Client media helpers', ->
  describe 'selectMedia', ->
    getPictureAreaDimensions = null
    beforeEach -> getPictureAreaDimensions = sinon.stub(clientMediaHelper, 'getPictureAreaDimensions').returns([1024,768])
    afterEach -> getPictureAreaDimensions.restore()

    it 'should check the screen size', ->
      clientMediaHelper.selectMedia picture
      getPictureAreaDimensions.calledOnce.should.be.ok

    it 'should return the biggest medium that fits in the usable area', ->
      medium = clientMediaHelper.selectMedia picture
      medium.src.should.equal 'http://example.com/800x600.jpg'

    it 'should fall back to the smallest medium if none fit', ->
      medium = clientMediaHelper.selectMedia pictureWithTooLargeMedia
      medium.src.should.equal 'http://example.com/1600x1200.jpg'

# TODO move original and thumbnail tests to picture_spec.coffee
describe 'Shared media helpers', ->
  describe 'getOriginal', ->
    it 'should return the original', ->
      sharedMediaHelper.getOriginal(pictureWithTooLargeMedia).src.should.equal 'http://example.com/2048x1536.jpg'

    it 'should return undefined when there is no original', ->
      should.not.exist sharedMediaHelper.getOriginal(picture)

  describe 'selectPictureThumbnail', ->
    it 'should return the medium whose height is closest to 240px', ->
      sharedMediaHelper.selectPictureThumbnail(picture).src.should.equal 'http://example.com/320x240.jpg'
