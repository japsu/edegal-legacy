should       = require 'should'
Q            = require 'q'
_            = require 'underscore'

require './helpers/db_helper'

{Album}      = require '../server/models/album'
{getAlbum, newAlbum, updateAlbum, deleteAlbum} = require '../server/services/album_service'

albums = [
  path: '/'
  title: 'Root'
  subalbums: [
    path: '/foo'
    title: 'Foo'
  ]
,
  path: '/foo'
  title: 'Foo'
  breadcrumb: [
    path: '/'
    title: 'Root'
  ]
  subalbums: [
    path: '/foo/bar'
    title: 'Foo Bar'
  ]
,
  path: '/foo/bar'
  title: 'Foo Bar'
  breadcrumb: [
    path: '/'
    title: 'Root'
  ,
    path: '/foo'
    title: 'Foo'
  ]
  pictures: [
    path: '/foo/bar/quux'
    title: 'Foo Bar Quux'
  ]
]

createAlbums = (success) ->
  Q.all(albums.map (album) ->
    Q.ninvoke new Album(album), 'save'
  ).then ->
    success() 
  .done()

describe 'Album service', ->
  describe 'getAlbum', ->
    beforeEach createAlbums

    it 'should return album by its path', (success) ->
      getAlbum('/').then (album) ->
        album.path.should.equal '/'
        success()
      .done()

    it 'should return album by the path of one of its pictures', (success) ->
      getAlbum('/foo/bar/quux').then (album) ->
        album.path.should.equal '/foo/bar'
        success()
      .done()

  describe 'newAlbum', ->
    it 'should create the root album', (success) ->
      newAlbum(null, path: '/', title: 'Test').then ->
        getAlbum('/')
      .then (album) ->
        album.title.should.equal 'Test'
        success()
      .done()

    it 'should create a leaf album', (success) ->
      newAlbum(null, path: '/', title: 'Test').then ->
        newAlbum('/', path: '/foo', title: 'Test Foo')
      .then ->
        getAlbum('/foo')
      .then (album) ->
        album.title.should.equal 'Test Foo'
        album.breadcrumb[0].path.should.equal '/'
        success()
      .done()

    it 'should update the parents subalbums', (success) ->
      newAlbum(null, path: '/', title: 'Test').then ->
        newAlbum('/', path: '/foo', title: 'Test Foo')
      .then ->
        getAlbum('/')
      .then (album) ->
        album.path.should.equal '/'
        album.subalbums[0].path.should.equal '/foo'
        success()
      .done()

  describe 'updateAlbum', ->
    beforeEach createAlbums

    it 'should save the changes and increment the album version', (success) ->
      baseVersion = null

      updateAlbum('/', (album) ->
        album.title.should.equal 'Root'
        album.title = 'New Title'
        baseVersion = album.version
      ).then (album) ->
        album.title.should.equal 'New Title'
        album.version.should.be.above baseVersion
        success()
      .done()

    it 'should raise on concurrent update', (success) ->
      updateAlbum('/', -> updateAlbum('/', _.identity)).fail (error) ->
        error.message.should.equal 'concurrent update'
        success()
      .done()

  describe 'deleteAlbum', ->
    beforeEach createAlbums

    it 'should delete the album and its subalbums', (success) ->
      deleteAlbum('/foo').then ->
        Q.all([getAlbum('/foo/bar/quux'), getAlbum('/foo/bar'), getAlbum('/foo')])
      .then (nulls) ->
        should.deepEqual nulls, [null, null, null]
        success()
      .done()

    it 'should remove the deleted album from its parents subalbums', (success) ->
      getAlbum('/').then (album) ->
        _.pluck(album.subalbums, 'path').should.include '/foo'
        deleteAlbum('/foo')
      .then ->
        getAlbum('/')
      .then (album) ->
        _.pluck(album.subalbums, 'path').should.not.include '/foo'
        success()
      .done()
