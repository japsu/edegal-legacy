fs = require 'fs'

james = require 'james'
jade = require 'james-jade-static'
stylus = require 'james-stylus'

browserify = require 'browserify'
coffeeify = require 'coffeeify'

mkdirp = require 'mkdirp'

BROWSERIFY_OPTS =
  debug: true

james.task 'browserify', ->
  browserify('./client/coffee/main.coffee')
    .transform(coffeeify)
    .bundle BROWSERIFY_OPTS, (err, src) ->
      mkdirp 'public/js', ->
        fs.writeFileSync 'public/js/bundle.js', src

transmogrifyJade = (file) ->
  james.read(file)
    .transform(jade)
    .write(file
      .replace('client/jade', 'public')
      .replace('.jade', '.html'))

james.task 'jade_static', ->
  james.list('client/jade/*.jade').forEach transmogrifyJade

transmogrifyStylus = (file) ->
  james.read(file)
    .transform(stylus)
    .write(file
      .replace('client/stylus', 'public/css')
      .replace('.styl', '.css'))

james.task 'stylus', ->
  james.list('client/stylus/*.styl').forEach transmogrifyStylus

james.task 'actual_watch', ->
  james.watch 'client/coffee/*.coffee', -> james.run 'browserify'
  james.watch 'client/jade/*.jade', (ev, file) -> transmogrifyJade file
  james.watch 'client/stylus/*.styl', (ev, file) -> transmogrifyStylus file

james.task 'default', ['browserify', 'jade_static', 'stylus']
james.task 'watch', ['default', 'actual_watch']