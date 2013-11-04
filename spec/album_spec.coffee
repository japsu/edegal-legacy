should       = require 'should'
Q            = require 'q'
_            = require 'underscore'

require './helpers/db_helper'

{Album}      = require '../server/models/album'
albumService = require '../server/services/album_service'

albums = [
  path: '/'
  title: 'Root'
  breadcrumb: []
  subalbums: [
    path: '/foo'
  ]
  pictures: []
,
  path: '/foo'
  title: 'Foo'
  breadcrumb: [
    path: '/'
  ]
  subalbums: [
    path: '/foo/bar'
  ]
  pictures: []
,
  path: '/foo/bar'
  title: 'Foo Bar'
  breadcrumb: [
    path: '/'
  ,
    path: '/foo'
  ]
  subalbums: []
  pictures: [
    path: '/foo/bar/quux'
  ]
]

describe 'Album service', ->
  beforeEach (done) ->
    Q.all(albums.map (album) ->
      Q.ninvoke new Album(album), 'save'
    ).then ->
      done() 
    .done()

  describe 'getAlbum', ->
    it 'should return album by its path', (success) ->
      getAlbum('/').then (album) ->
        album.path.should.equal '/'
        success()

    it 'should return album by the path of one of its pictures', (success) ->
      getAlbum('/foo/bar/quux').then (album) ->
        album.path.should.equal '/foo/bar'
        success()

  describe 'newAlbum', ->
    it 'should create the root album'
    it 'should create a leaf album'

  describe 'saveAlbum', ->
    it 'should increment the album version'
    it 'should save the album'

  describe 'deleteAlbum', ->
    it 'should delete the album and its subalbums'
    it 'should remove the deleted album from its parents subalbums'
