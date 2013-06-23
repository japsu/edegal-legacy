should = require 'should'
sinon = require 'sinon'

{Picture} = require '../client/js/models/picture.coffee'
mediaHelper = {selectMedia} = require '../client/js/views/helpers/media_helper.coffee'

describe 'Media helpers', ->
  describe 'selectMedia', ->
    picture = new Picture
      path: '/selectmedia/picture'
      media: [
        {
          width: '800'
          height: '600'
          src: 'http://example.com/800x600.jpg'
        }
        {
          width: '1600'
          height: '1200'
          src: 'http://example.com/1600x1200.jpg'
        }
        {
          width: '640'
          height: '480'
          src: 'http://example.com/640x480.jpg'
        }
      ]

    pictureWithTooLargeMedia = new Picture
      path: '/selectmedia/picture-with-too-large-media'
      media: [
        {
          width: '2048'
          height: '1536'
          src: 'http://example.com/2048x1536.jpg'
        }
        {
          width: '1600'
          height: '1200'
          src: 'http://example.com/1600x1200.jpg'
        }
      ]

    getPictureAreaDimensions = null
    beforeEach -> getPictureAreaDimensions = sinon.stub(mediaHelper, 'getPictureAreaDimensions').returns([1024,768])
    afterEach -> getPictureAreaDimensions.restore()

    it 'should check the screen size', ->
      selectMedia picture
      getPictureAreaDimensions.calledOnce.should.be.ok

    it 'should return the biggest medium that fits in the usable area', ->
      medium = selectMedia picture
      medium.src.should.equal 'http://example.com/800x600.jpg'

    it 'should fall back to the smallest medium if none fit', ->
      medium = selectMedia pictureWithTooLargeMedia
      medium.src.should.equal 'http://example.com/1600x1200.jpg'
