$           = require 'jQuery'
_           = require 'underscore'
_.str       = require 'underscore.string'
path        = require 'path'
config      = require './config.coffee'
angular     = require 'angular'
ngRoute     = require 'angular-route'
md5         = require 'angular-md5'
animate     = require 'angular-animate'
gravatar    = require 'angular-gravatar'
ngInfScrl   = require 'angular-infinite-scroll'
bootstrap   = require 'angular-strap'
templates   = require 'angular-strap-templates'
Firebase    = require 'firebase'
angularfire = require 'angularfire'
SimpleLogin = require 'firebase-simple-login'
ngFileUpload = require 'ng-file-upload'
ngProgress  = require 'ng-progress'
partials    = require './partials'

module = angular.module 'app', [
  'ngRoute'
  'ngAnimate'
  'firebase'
  'partials'
  'ngProgress'
  'ui.gravatar'
  'angularFileUpload'
  'infinite-scroll'
  'mgcrea.ngStrap.modal'
  'mgcrea.ngStrap.aside'
  'mgcrea.ngStrap.tooltip'
  'mgcrea.ngStrap.dropdown'
]

module.controller 'loginController', require './controllers/loginController.coffee'
module.controller 'signupController', require './controllers/signupController.coffee'
module.controller 'uploadController', require './controllers/uploadController.coffee'
module.controller 'filesController', require './controllers/filesController.coffee'
module.controller 'indexController', require './controllers/indexController.coffee'

module.directive 'ngFilePaste', require './directives/ngFilePaste.coffee'
module.directive 'youtubeEmbed', require './directives/youtubeEmbed.coffee'
module.directive 'header', require './directives/header.coffee'

module.service 'userService', require './services/userService.coffee'
module.service 'imgurService', require './services/imgurService.coffee'
module.service 'youtubeService', require './services/youtubeService.coffee'
module.service 'fileService', require './services/fileService.coffee'

module.service 'FirebaseService', ->
  new Firebase config.firebase.address

module.filter 'capitalize', () -> _.str.capitalize

module.run ($rootScope, $location) ->
  $rootScope.$on '$routeChangeError', ->
    $location.path '/login'

module.config ($routeProvider, $locationProvider, $modalProvider) ->

  $routeProvider
    .when '/',
      templateUrl: 'main/index.html'
      controller: 'indexController'
      reloadOnSearch: false
      resolve:
        user: (userService) -> userService.getCurrentUser()

    .when '/s/:priority',
      templateUrl: 'main/index.html'
      controller: 'indexController'
      resolve:
        user: (userService) -> userService.getCurrentUser()

    .when '/login',
      templateUrl: 'login/index.html'
      controller: 'loginController'

    .when '/signup',
      templateUrl: 'signup/index.html'
      controller: 'signupController'

    .when '/logout',
      redirectTo: (userService) ->
        'login'
      resolve:
        logout: (userService) ->
          userService.auth.$logout()

    .when '/upload',
      templateUrl: 'main/index.html'
      controller: 'indexController'
      resolve:
        user: (userService) -> userService.getCurrentUser()

    .when '/files/:id',
      templateUrl: 'file/index.html'
      controller: 'filesController'
      resolve:
        user: (userService) -> userService.getCurrentUser()

    .when '/404',
      templateUrl: '404/index.html'
      controller: ($scope, user) ->
        $scope.user = user
      resolve:
        user: (userService) -> userService.getCurrentUser()
