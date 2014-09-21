path       = require 'path'

browserify = require 'browserify'
CSSmin     = require 'gulp-minify-css'
gulp       = require 'gulp'
gutil      = require 'gulp-util'
jade       = require 'gulp-jade'
nib        = require 'nib'
prefix     = require 'gulp-autoprefixer'
rename     = require 'gulp-rename'
source     = require 'vinyl-source-stream'
streamify  = require 'gulp-streamify'
stylus     = require 'gulp-stylus'
uglify     = require 'gulp-uglify'


production = process.env.NODE_ENV is 'production'


paths =
  scripts:
    destination: './public/'
    filename: 'bundle.js'
    source: './client/js/main.coffee'
    watch: './client/js/**/*.coffee'
  index:
    destination: './public/'
    source: './client/index.jade'
    watch: './client/**/*.jade'
  styles:
    destination: './public/'
    source: './client/css/style.styl'
    watch: './client/css/*.styl'
  assets:
    destination: './public/'
    source: './client/assets/**/*.*'
    watch: './client/assets/**/*.*'


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
  gulp.watch paths.assets.watch, ['assets']
  gulp.watch paths.index.source, ['index']
  gulp.watch paths.scripts.watch, ['scripts']
  gulp.watch paths.styles.watch, ['styles']


gulp.task 'build', ['scripts', 'index', 'styles', 'assets']
gulp.task 'default', ['build', 'watch', 'server']
