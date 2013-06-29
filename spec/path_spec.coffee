should = require 'should'
_ = require 'underscore'

{Album} = require '../client/js/models/album'
{makeBreadcrumb, slugify} = require '../shared/helpers/path_helper'

describe 'Path helpers', ->
  describe 'slugify', ->
    it 'should work with an empty string', ->
      slugify('').should.equal ''

    it 'should make human-readable slugs', ->
      slugify('Desucon 2013').should.equal 'desucon-2013'

    it 'should convert Scandinavic chars to their non-dotty counterparts', ->
      slugify('Yli-Öön mangapäivä').should.equal 'yli-oon-mangapaiva'

  describe 'makeBreadcrumb', ->
    album =
      path: '/make-breadcrumb',
      title: 'Make Breadcrumb',
      breadcrumb: [
        {
          path: '/',
          title: 'Bakery'
        }
      ]
      subalbums: [
        {
          path: '/make-breadcrumb/crusty'
          title: 'Crusty'
        }
      ]
      pictures: [
        {
          path: '/make-breadcrumb/crunchy'
          title: 'Crunchy'
        }
      ]

    root = album.breadcrumb[0]
    albumModel = new Album album

    it 'should work with a single album', ->
      breadcrumb = makeBreadcrumb album

      breadcrumb.length.should.equal 2

      breadcrumb[0].path.should.equal root.path
      breadcrumb[0].title.should.equal root.title

      breadcrumb[1].path.should.equal album.path
      breadcrumb[1].title.should.equal album.title

    it 'should work with multiple albums', ->
      subalbum = album.subalbums[0]
      breadcrumb = makeBreadcrumb album, subalbum

      breadcrumb.length.should.equal 3

      breadcrumb[0].path.should.equal root.path
      breadcrumb[0].title.should.equal root.title

      breadcrumb[1].path.should.equal album.path
      breadcrumb[1].title.should.equal album.title

      breadcrumb[2].path.should.equal subalbum.path
      breadcrumb[2].title.should.equal subalbum.title

    it 'should work with an album and a picture', ->
      picture = album.pictures[0]
      breadcrumb = makeBreadcrumb album, picture

      breadcrumb.length.should.equal 3

      breadcrumb[0].path.should.equal root.path
      breadcrumb[0].title.should.equal root.title

      breadcrumb[1].path.should.equal album.path
      breadcrumb[1].title.should.equal album.title

      breadcrumb[2].path.should.equal picture.path
      breadcrumb[2].title.should.equal picture.title

    it 'should work with Backbone models', ->
      pictureModel = albumModel.get('pictures').at(0)
      breadcrumb = makeBreadcrumb albumModel, pictureModel

      breadcrumb.length.should.equal 3

      breadcrumb[0].path.should.equal root.path
      breadcrumb[0].title.should.equal root.title

      breadcrumb[1].path.should.equal albumModel.get('path')
      breadcrumb[1].title.should.equal albumModel.get('title')

      breadcrumb[2].path.should.equal pictureModel.get('path')
      breadcrumb[2].title.should.equal pictureModel.get('title')
