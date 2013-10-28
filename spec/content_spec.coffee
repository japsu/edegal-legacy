should = require 'should'

{fakeBackboneAjax} = require './helpers/ajax_helper.coffee'

{Album, albums} = require '../client/js/models/album.coffee'
{pictures} = require '../client/js/models/picture.coffee'
{getContent} = require '../client/js/models/helpers/content_helper.coffee'

describe 'getContent', ->
  beforeEach ->
    # TODO clear all Albums and Models from Backbone.Relational.store without nuking the model scopes

  describe 'cache hits', ->
    it 'should return the album and no picture when given a path to a cached album', (callback) ->
      albums.add new Album
        path: '/album1'
        pictures: []

      getContent('/album1').then (content) ->
        {album, picture} = content

        should.exist album
        should.not.exist picture

        album.get('path').should.equal '/album1'

        callback()
      .done()

    it 'should return a picture and its album when given a path to a cached picture', (callback) ->
      album = new Album
        path: '/album2'
        pictures: [
          path: '/album2/pic1'
        ]

      albums.add(album)

      picture = album.get('pictures').at(0)
      pictures.add picture

      getContent('/album2/pic1').then (content) ->
        {album, picture} = content

        should.exist album
        should.exist picture

        album.get('path').should.equal '/album2'
        picture.get('path').should.equal '/album2/pic1'

        callback()
      .done()

  describe 'cache misses', ->
    fakeAjax = null

    beforeEach ->
      fakeAjax = fakeBackboneAjax
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

    it 'should fetch an album when it is not present in the cache, add it to cache and return it', (callback) ->
      getContent('/album3').then (fetchedContent) ->
        checkContent fetchedContent
        getContent '/album3'
      .then (cachedContent) ->
        checkContent cachedContent
        callback()
      .done()

      checkContent = (content) ->
        {album, picture} = content

        should.exist album
        should.not.exist picture

        album.get('path').should.equal '/album3'
        album.get('title').should.equal 'Album Three'

        fakeAjax.calledOnce.should.be.ok
        fakeAjax.calledWithMatch(url: '/v2/album3').should.be.ok

    it 'should fetch the album of a picture when it is not present in the cache, add the album and the picture to the cache and return them', (callback) ->
      getContent('/album4/pic1').then (fetchedContent) ->
        checkContent fetchedContent
        getContent '/album4/pic1'
      .then (cachedContent) ->
        checkContent cachedContent
        callback()
      .done()

      checkContent = (content) ->
        {album, picture} = content

        should.exist album
        should.exist picture

        album.get('path').should.equal '/album4'
        album.get('title').should.equal 'Album Four'

        picture.get('path').should.equal '/album4/pic1'
        picture.get('title').should.equal 'DSCF0613'
        picture.get('album').get('path').should.equal '/album4'

        fakeAjax.calledOnce.should.be.ok
        fakeAjax.calledWithMatch(url: '/v2/album4/pic1').should.be.ok

  it 'should fail gracefully when given a path that does not exist on the server'