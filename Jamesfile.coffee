james = require 'james'
jade = require 'james-jade-static'
stylus = require 'james-stylus'
uglify = require 'james-uglify'

browserify = require 'browserify'
coffeeify = require 'coffeeify'

copyFile = (file) -> james.read(file).write(file.replace('client/', 'public/'))

james.task 'copy_files', -> james.list('client/images/*').forEach copyFile

transmogrifyCoffee = (debug) ->
  bundle = james.read browserify('./client/coffee/main.coffee')
    .transform(coffeeify)
    .bundle
      debug: debug

  bundle = bundle.transform(uglify) unless debug
  bundle.write('public/js/bundle.js')

james.task 'browserify', -> transmogrifyCoffee false
james.task 'browserify_debug', -> transmogrifyCoffee true

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
  james.watch 'client/coffee/*.coffee', -> transmogrifyCoffee true
  james.watch 'client/jade/*.jade', (ev, file) -> transmogrifyJade file
  james.watch 'client/stylus/*.styl', (ev, file) -> transmogrifyStylus file
  james.watch 'client/images/*', (ev, file) -> copyFile file

james.task 'build_debug', ['browserify_debug', 'jade_static', 'stylus', 'copy_files']
james.task 'build', ['browserify', 'jade_static', 'stylus', 'copy_files']
james.task 'default', ['build_debug']
james.task 'watch', ['build_debug', 'actual_watch']