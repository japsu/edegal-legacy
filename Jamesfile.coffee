james  = require 'james'
jade   = require 'james-jade-static'
stylus = require 'james-stylus'
uglify = require 'james-uglify'
cssmin = require 'james-cssmin'

browserify = require 'browserify'
shim = require 'browserify-shim'
coffeeify  = require 'coffeeify'

copyFile = (file) -> james.read(file).write(file.replace('client/', 'public/'))

FILES_TO_COPY = [
  'client/**/*.css',
  'client/**/*.jpg',
  'client/**/*.png',
  'client/**/*.gif',
]

BOWER_CSS = [
  'components/normalize-css/normalize.css'
]

james.task 'copy_files', -> FILES_TO_COPY.forEach (glob) -> james.list(glob).forEach copyFile

transmogrifyCoffee = (debug) ->
  libs =
    jquery:
      path: './components/jquery/jquery.js'
      exports: '$'

    transparency:
      path: './components/transparency/dist/transparency.min.js'
      exports: 'Transparency'
      depends: 
        jquery: '$'
        underscore: '_'

    'backbone-relational':
      path: './components/backbone-relational/backbone-relational.js'
      exports: 'Backbone'
      depends: 
        jquery: '$'
        underscore: '_'
        backbone: 'Backbone'

  bundle = james.read shim(browserify(), libs)
    .require('./client/js/main.coffee', entry: true)
    .transform(coffeeify)
    .bundle
      debug: debug

  bundle = bundle.transform(uglify) unless debug
  bundle.write('public/js/bundle.js')

james.task 'browserify', -> transmogrifyCoffee false
james.task 'browserify_debug', -> transmogrifyCoffee true

transmogrifyJade = (file) ->
  james.read(file)
    .transform(jade(filename: file))
    .write(file
      .replace('client', 'public')
      .replace('.jade', '.html'))

james.task 'jade_static', ->
  james.list('client/*.jade').forEach transmogrifyJade

james.task 'compress_css', ->
  dest = james.dest 'public/css/bundle.css'

  BOWER_CSS.forEach (file) ->
    james.read(file).transform(cssmin).write(dest)
  james.list('client/**/*.css').forEach (file) ->
    james.read(file).transform(cssmin).write(dest)
  james.list('client/**/*.styl').forEach (file) ->
    james.read(file).transform(stylus).transform(cssmin).write(dest)

james.task 'watch', ->
  james.watch 'client/**/*.coffee', ['browserify_debug']
  james.watch 'client/**/*.jade', ['jade_static']
  james.watch 'client/**/*.styl', ['compress_css']

  FILES_TO_COPY.forEach (glob) -> james.watch glob, (ev, file) -> copyFile file

james.task 'build_debug', ['browserify_debug', 'jade_static', 'compress_css', 'copy_files']
james.task 'build', ['browserify', 'jade_static', 'compress_css', 'copy_files']
james.task 'default', ['build_debug']
