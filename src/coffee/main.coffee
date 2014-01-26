_           = require 'underscore'
path        = require 'path'
config      = require './config.coffee'

angular     = require 'angular'
ngRoute     = require 'angular-route'
md5         = require 'angular-md5'
animate     = require 'angular-animate'
gravatar    = require 'angular-gravatar'

bootstrap   = require 'angular-strap'
templates   = require 'angular-strap-templates'
Firebase    = require 'firebase'
angularfire = require 'angularfire'
SimpleLogin = require 'firebase-simple-login'
ngFileUpload = require 'ng-file-upload'

module = angular.module 'app', [
  'ngRoute'
  'ngAnimate'
  'firebase'
  'ui.gravatar'
  'angularFileUpload'
  'mgcrea.ngStrap.modal'
  'mgcrea.ngStrap.aside'
  'mgcrea.ngStrap.tooltip'
  'mgcrea.ngStrap.dropdown'
]

module.controller 'loginController', require './controllers/loginController.coffee'
module.controller 'signupController', require './controllers/signupController.coffee'
module.controller 'uploadController', require './controllers/uploadController.coffee'
module.controller 'headerController', require './controllers/headerController.coffee'
module.controller 'filesController', require './controllers/filesController.coffee'
module.controller 'indexController', require './controllers/indexController.coffee'

module.directive 'ngFilePaste', require './directives/ngFilePaste.coffee'

module.service 'userService', require './services/userService.coffee'
module.service 'imgurService', require './services/imgurService.coffee'

module.service 'fileService', ($firebase) ->
  files: new Firebase config.firebase.address + 'files'

module.service 'FirebaseService', ->
  new Firebase config.firebase.address

module.filter 'thumbnail', () -> (val) ->
  basename = path.basename val, path.extname(val)
  val.replace basename, basename + 'b'


module.config ($routeProvider, $locationProvider, $modalProvider) ->
  $locationProvider.html5Mode true

  $routeProvider
    .when '/',
      templateUrl: '/partials/main/index.html'
      controller: 'indexController'

    .when '/files/:id',
      templateUrl: '/partials/file/index.html'
      controller: 'filesController'
