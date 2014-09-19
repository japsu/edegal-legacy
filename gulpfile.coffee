browserify = require 'browserify'
coffeeify  = require 'coffeeify'
CSSmin     = require 'gulp-minify-css'
es         = require 'event-stream'
gulp       = require 'gulp'
gutil      = require 'gulp-util'
jade       = require 'gulp-jade'
path       = require 'path'
plumber    = require 'gulp-plumber'
prefix     = require 'gulp-autoprefixer'
rename     = require 'gulp-rename'
source     = require 'vinyl-source-stream'
streamify  = require 'gulp-streamify'
stylus     = require 'gulp-stylus'
uglify     = require 'gulp-uglify'
nib        = require 'nib'


production = process.env.NODE_ENV is 'production'


paths =
  scripts:
    source: './client/js/main.coffee'
    destination: './public/'
    filename: 'bundle.js'
  index:
    source: './client/index.jade'
    destination: './public/'
  styles:
    source: './client/css/style.styl'
    watch: './client/css/*.styl'
    destination: './public/'
  assets:
    source: './client/assets/**/*.*'
    watch: './client/assets/**/*.*'
    destination: './public/'


handleError = (err) ->
  gutil.log err
  gutil.beep()
  this.emit 'end'


gulp.task 'index', ->
  gulp
    .src paths.index.source
    .pipe jade pretty: not production
    .pipe rename 'index.html'
    .on 'error', handleError
    .pipe gulp.dest paths.index.destination


gulp.task 'scripts', ->
  bundle = browserify
    entries: [paths.scripts.source]
    debug: not production    
    extensions: ['.coffee']

  build = bundle.bundle()
    .on 'error', handleError
    .pipe source paths.scripts.filename

  build = build.pipe(streamify(uglify())) if production

  build
    .pipe gulp.dest paths.scripts.destination


gulp.task 'styles', ->
  styles = gulp
    .src paths.styles.source
    .pipe(stylus(set: ['include css'], filename: paths.styles.source, use: nib()))
    .on 'error', handleError
    .pipe prefix 'last 2 versions', 'Chrome 34', 'Firefox 28', 'iOS 7'

  styles = styles.pipe(CSSmin()) if production

  styles.pipe gulp.dest paths.styles.destination


gulp.task 'assets', ->
  gulp
    .src paths.assets.source
    .pipe gulp.dest paths.assets.destination


gulp.task 'server', ->
  config = require './server_config.json'
  server = require './server/server'
  console?.log "server in #{config.host}:#{config.port}"
  server.app.listen config.port, config.host


gulp.task 'watch', ->
  gulp.watch 'client/coffee/**/*.coffee', ['scripts']
  gulp.watch 'client/jade/**/*.jade', ['scripts']
  gulp.watch 'data/*.json', ['scripts']
  gulp.watch 'client/stylus/*.styl', ['styles']
  gulp.watch 'client/assets/**/*.*', ['assets']


gulp.task "build", ['scripts', 'index', 'styles', 'assets']
gulp.task "default", ["build", "watch", "server"]