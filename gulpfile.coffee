path       = require 'path'
gulp       = require 'gulp'
gutil      = require 'gulp-util'
jade       = require 'gulp-jade'
stylus     = require 'gulp-stylus'
CSSmin     = require 'gulp-minify-css'
browserify = require 'gulp-browserify'
rename     = require 'gulp-rename'
uglify     = require 'gulp-uglify'
coffeeify  = require 'coffeeify'
express    = require 'express'
lr         = require 'tiny-lr'
livereload = require 'gulp-livereload'
reloadServer = lr()

compileCoffee = (debug = false) ->

  config =
    debug: debug
    transform: ['coffeeify']
    shim:
      angular:
        path: './vendor/angular/angular.js'
        exports: 'angular'
      'angular-ui':
        path: './vendor/angular-bootstrap/ui-bootstrap.js'
        exports: 'angular'
      'angular-ui-templates':
        path: './vendor/angular-bootstrap/ui-bootstrap-tpls.js'
        exports: 'angular'
      'angular-md5':
        path: './vendor/angular-gravatar/build/md5.js'
        exports: 'angular'
      'angular-gravatar':
        path: './vendor/angular-gravatar/build/angular-gravatar.js'
        exports: 'angular'
        depends:
          'angular-md5': 'angular'
      'ng-file-upload':
        path: './vendor/ng-file-upload/angular-file-upload.js'
        exports: 'ngFileUpload'
      'angular-route':
        path: './vendor/angular-route/angular-route.js'
        exports: 'ngRoute'
      'firebase':
        path: './vendor/firebase/firebase.js'
        exports: 'Firebase'
      'angularfire':
        path: './vendor/angularfire/angularfire.js'
        exports: 'angularfire'
      'firebase-simple-login':
        path: './vendor/firebase-simple-login/firebase-simple-login.js'
        exports: 'FirebaseSimpleLogin'

  bundle = gulp
    .src('./src/coffee/main.coffee', read: false)
    .pipe(browserify(config))
    .pipe(rename('bundle.js'))

  bundle.pipe(uglify()) unless debug

  bundle
    .pipe(gulp.dest('./public/js/'))
    .pipe(livereload(reloadServer))

compileJade = (debug = false) ->
  gulp
    .src('src/jade/**/*.jade')
    .pipe(jade(pretty: debug))
    .pipe(gulp.dest('public/'))
    .pipe livereload(reloadServer)

compileStylus = (debug = false) ->
  styles = gulp
    .src('src/stylus/style.styl')
    .pipe(stylus({set: ['include css']}))

  styles.pipe(CSSmin()) unless debug

  styles.pipe(gulp.dest('public/css/'))
    .pipe livereload reloadServer

# Build tasks
gulp.task "jade-production", -> compileJade()
gulp.task 'stylus-production', ->compileStylus()
gulp.task 'coffee-production', -> compileCoffee()

# Development tasks
gulp.task "jade", -> compileJade(true)
gulp.task 'stylus', -> compileStylus(true)
gulp.task 'coffee', -> compileCoffee(true)


gulp.task 'copy-assets', ->
  gulp.src('vendor/bootstrap/dist/fonts/*')
    .pipe gulp.dest 'public/css/fonts'


gulp.task "server", ->
  app = express()
  app.use express.static './public'
  app.get '*', (req, res) ->
    res.sendfile './public/index.html'
  app.listen 3000

  # staticFiles = new nodeStatic.Server './public'
  # require('http').createServer (req, res) ->
  #   req.addListener 'end', ->
  #     staticFiles.serve req, res
  #   req.resume()
  # .listen 9001

gulp.task "watch", ->
  reloadServer.listen 35729, (err) ->
    console.error err if err?

    gulp.watch "src/coffee/*.coffee", ->
      gulp.run "coffee"

    gulp.watch "src/jade/**/*.jade", ->
      gulp.run "jade"

    gulp.watch "src/stylus/*.styl", ->
      gulp.run "stylus"

gulp.task "build", ->
  gulp.run "coffee-production", "jade-production", "stylus-production", "copy-assets"

gulp.task "default", ->
  gulp.run "coffee", "jade", "stylus", "copy-assets", "watch", "server"
