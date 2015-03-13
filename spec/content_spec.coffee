should = require 'should'
sinon = require 'sinon'
Promise = require 'bluebird'

albumService = require '../client/js/services/album_service.coffee'


fakeGetJson = (content) ->
  sinon.stub albumService, 'getJSON', (url) -> Promise.resolve content[url]


describe 'getContent', ->
  describe 'cache misses', ->
    fakeAjax = null

    beforeEach ->
      fakeAjax = fakeGetJson
        '/v2/album3':
          path: '/album3'
          title: 'Album Three'
          pictures: []

        '/v2/album4/pic1':
          path: '/album4'
          title: 'Album Four'
          pictures: [
            title: 'DSCF0613'
            path: '/album4/pic1'
          ]

    afterEach ->
      fakeAjax.restore()

    it 'should fetch an album add it to cache and return it', (callback) ->
      albumService.getContent('/album3').then (fetchedContent) ->
        checkContent fetchedContent
        albumService.getContent '/album3'
      .then (cachedContent) ->
        checkContent cachedContent
        callback()
      .catch (error) ->
        callback error

      checkContent = (content) ->
        {album, picture} = content

        should.exist album
        should.not.exist picture

        album.path.should.equal '/album3'
        album.title.should.equal 'Album Three'

        fakeAjax.calledOnce.should.be.ok
        fakeAjax.calledWithMatch('/v2/album3').should.be.ok

    it 'should fetch the album of a picture add the album and the picture to the cache and return them', (callback) ->
      albumService.getContent('/album4/pic1').then (fetchedContent) ->
        checkContent fetchedContent
        albumService.getContent '/album4/pic1'
      .then (cachedContent) ->
        checkContent cachedContent
        callback()
      .catch (error) ->
        callback error

      checkContent = (content) ->
        {album, picture} = content

        should.exist album
        should.exist picture

        album.path.should.equal '/album4'
        album.title.should.equal 'Album Four'

        picture.path.should.equal '/album4/pic1'
        picture.title.should.equal 'DSCF0613'

        fakeAjax.calledOnce.should.be.ok
        fakeAjax.calledWithMatch('/v2/album4/pic1').should.be.ok

  it 'should fail gracefully when given a path that does not exist on the server'
