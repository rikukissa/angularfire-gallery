fs         = require 'fs'
path       = require 'path'
gulp       = require 'gulp'
gutil      = require 'gulp-util'
jade       = require 'gulp-jade'
concat     = require 'gulp-concat'
stylus     = require 'gulp-stylus'
CSSmin     = require 'gulp-minify-css'
browserify = require 'gulp-browserify'
rename     = require 'gulp-rename'
uglify     = require 'gulp-uglify'
coffeeify  = require 'coffeeify'
express    = require 'express'
lr         = require 'tiny-lr'
livereload = require 'gulp-livereload'
ngHtml2Js  = require 'gulp-ng-html2js'
reloadServer = lr()

compileCoffee = (debug = false) ->

  config =
    debug: debug
    transform: ['coffeeify']
    shim:
      angular:
        path: './vendor/angular/angular.js'
        exports: 'angular'

      'angular-strap':
        path: './vendor/angular-strap/dist/angular-strap.js'
        exports: 'angular'
        depends:
          angular: 'angular'

      'angular-strap-templates':
        path: './vendor/angular-strap/dist/angular-strap.tpl.js'
        exports: 'angular'

      'angular-md5':
        path: './vendor/angular-gravatar/build/md5.js'
        exports: 'angular'

      'angular-gravatar':
        path: './vendor/angular-gravatar/build/angular-gravatar.js'
        exports: 'angular'
        depends:
          'angular-md5': 'angular'

      'jQuery':
        path: './vendor/jquery/jquery.js'
        exports: '$'

      'angular-infinite-scroll':
        path: './vendor/ngInfiniteScroll/ng-infinite-scroll.js'
        exports: 'angular'
        depends:
          'jQuery': '$'
          'angular': 'angular'

      'ng-file-upload':
        path: './vendor/ng-file-upload/angular-file-upload.js'
        exports: 'ngFileUpload'

      'angular-route':
        path: './vendor/angular-route/angular-route.js'
        exports: 'angular'

      'angular-animate':
        path: './vendor/angular-animate/angular-animate.js'
        exports: 'angular'

      'ng-progress':
        path: './vendor/ngprogress/build/ngProgress.js'
        exports: 'angular'

      'firebase':
        path: './vendor/firebase/firebase.js'
        exports: 'Firebase'

      'angularfire':
        path: './vendor/angularfire/angularfire.js'
        exports: 'angularfire'

      'firebase-simple-login':
        path: './vendor/firebase-simple-login/firebase-simple-login.js'
        exports: 'FirebaseSimpleLogin'

  # Generate partials file to src/coffee/partials.js
  gulp
    .src('src/jade/partials/**/*.jade')
    .pipe(jade(pretty: debug))
    .pipe(ngHtml2Js(
        moduleName: 'partials'
    ))
    .pipe(concat("partials.js"))
    .pipe(gulp.dest("./src/coffee/"))

  # Generate bundle
  bundle = gulp
    .src('./src/coffee/main.coffee', read: false)
    .pipe(browserify(config))
    .pipe(rename('bundle.js'))

  bundle = bundle.pipe(uglify(mangle: false)) unless debug

  bundle
    .pipe(gulp.dest('./public/js/'))
    .pipe(livereload(reloadServer))
    .on 'end', ->
      # Remove partials file
      fs.unlink './src/coffee/partials.js'


compileJade = (debug = false) ->
  gulp
    .src('src/jade/index.jade')
    .pipe(jade(pretty: debug))
    .pipe(gulp.dest('public/'))
    .pipe livereload(reloadServer)


compileStylus = (debug = false) ->
  styles = gulp
    .src('src/stylus/style.styl')
    .pipe(stylus({set: ['include css']}))

  styles = styles.pipe(CSSmin()) unless debug

  styles.pipe(gulp.dest('public/css/'))
    .pipe livereload reloadServer

gulp.task 'stylus', -> compileStylus(true)
gulp.task 'stylus-production', ->compileStylus()

gulp.task "jade", -> compileJade(true)
gulp.task "jade-production", -> compileJade()

gulp.task 'coffee', -> compileCoffee(true)
gulp.task 'coffee-production', -> compileCoffee()

gulp.task 'copy-assets', ->
  gulp.src('vendor/bootstrap/dist/fonts/*')
    .pipe gulp.dest 'public/fonts/'

gulp.task "server", ->
  app = express()
  app.use express.static './public'
  app.get '*', (req, res) ->
    res.sendfile './public/index.html'
  app.listen 3000

gulp.task "watch", ->
  reloadServer.listen 35729, (err) ->
    console.error err if err?

    gulp.watch "src/coffee/**/*.coffee", ->
      gulp.run "coffee"

    gulp.watch "src/jade/partials/**/*.jade", ->
      gulp.run "coffee"

    gulp.watch "src/jade/index.jade", ->
      gulp.run "jade"

    gulp.watch "src/stylus/*.styl", ->
      gulp.run "stylus"

gulp.task "build", ->
  gulp.run "coffee-production", "jade-production", "stylus-production", "copy-assets"

gulp.task "default", ->
  gulp.run "coffee", "jade", "stylus", "copy-assets", "watch", "server"
