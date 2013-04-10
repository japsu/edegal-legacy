james = require 'james'
jade = require 'james-jade-static'
stylus = require 'james-stylus'
uglify = require 'james-uglify'

browserify = require 'browserify'
coffeeify = require 'coffeeify'

copyFile = (file) -> james.read(file).write(file.replace('client/', 'public/'))

james.task 'copy_files', -> james.list('client/images/*').forEach copyFile

james.task 'browserify', ->
  bundle = browserify('./client/coffee/main.coffee')
    .transform(coffeeify)
    .bundle()

  james.read(bundle)
    .transform(uglify)
    .write('public/js/bundle.js')

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
      .replace('.stylus', '.css')
      .replace('.styl', '.css'))

james.task 'stylus', ->
  james.list('client/stylus/*.styl').forEach transmogrifyStylus

james.task 'actual_watch', ->
  james.watch 'client/coffee/*.coffee', -> james.run 'browserify'
  james.watch 'client/jade/*.jade', (ev, file) -> transmogrifyJade file
  james.watch 'client/stylus/*.styl', (ev, file) -> transmogrifyStylus file
  james.watch 'client/images/*', (ev, file) -> copyFile file

james.task 'default', ['browserify', 'jade_static', 'stylus', 'copy_files']
james.task 'watch', ['default', 'actual_watch']