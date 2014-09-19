should       = require 'should'
Promise      = require 'bluebird'
_            = require 'lodash'

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
  Promise.all(albums.map (album) ->
    new Album(album).saveAsync()
  ).then ->
    success() 

describe 'Album service', ->
  describe 'getAlbum', ->
    beforeEach createAlbums

    it 'should return album by its path', (success) ->
      getAlbum('/').then (album) ->
        album.path.should.equal '/'
        success()

    it 'should return album by the path of one of its pictures', (success) ->
      getAlbum('/foo/bar/quux').then (album) ->
        album.path.should.equal '/foo/bar'
        success()

  describe 'newAlbum', ->
    it 'should create the root album', (success) ->
      newAlbum(null, path: '/', title: 'Test').then ->
        getAlbum('/')
      .then (album) ->
        album.title.should.equal 'Test'
        success()

    it 'should create a leaf album', (success) ->
      newAlbum(null, path: '/', title: 'Test').then ->
        newAlbum('/', path: '/foo', title: 'Test Foo')
      .then ->
        getAlbum('/foo')
      .then (album) ->
        album.title.should.equal 'Test Foo'
        album.breadcrumb[0].path.should.equal '/'
        success()

    it 'should update the parents subalbums', (success) ->
      newAlbum(null, path: '/', title: 'Test').then ->
        newAlbum('/', path: '/foo', title: 'Test Foo')
      .then ->
        getAlbum('/')
      .then (album) ->
        album.path.should.equal '/'
        album.subalbums[0].path.should.equal '/foo'
        success()

  describe 'updateAlbum', ->
    beforeEach createAlbums

    it 'should save the changes', (success) ->
      baseVersion = null

      updateAlbum('/', (album) ->
        album.title.should.equal 'Root'
        album.title = 'New Title'
      ).then (album) ->
        album.title.should.equal 'New Title'
        success()

  describe 'deleteAlbum', ->
    beforeEach createAlbums

    it 'should delete the album and its subalbums', (success) ->
      deleteAlbum('/foo').then ->
        Promise.all([getAlbum('/foo/bar/quux'), getAlbum('/foo/bar'), getAlbum('/foo')])
      .then (nulls) ->
        should.deepEqual nulls, [null, null, null]
        success()

    it 'should remove the deleted album from its parents subalbums', (success) ->
      getAlbum('/').then (album) ->
        _.pluck(album.subalbums, 'path').should.containEql '/foo'
        deleteAlbum('/foo')
      .then ->
        getAlbum('/')
      .then (album) ->
        _.pluck(album.subalbums, 'path').should.not.containEql '/foo'
        success()
