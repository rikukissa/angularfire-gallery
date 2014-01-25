_           = require 'underscore'
path        = require 'path'
async       = require 'async'

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
]

module.service 'fileService', ($firebase) ->
  files: new Firebase 'https://ttcc.firebaseio.com/files'

module.service 'FirebaseService', ->
  new Firebase 'https://ttcc.firebaseio.com/'

module.service 'userService', (FirebaseService, $firebase, $firebaseSimpleLogin, $q) ->
  deferred = $q.defer()

  usersRef = new Firebase 'https://ttcc.firebaseio.com/users'

  auth = $firebaseSimpleLogin FirebaseService

  users = $firebase usersRef

  auth: auth
  users: users
  create: (userData) ->
    auth
      .$createUser(userData.email, userData.password)
      .then (user) ->
        users.$child(user.id).$set _.omit(userData, 'password')
      , (err) ->
        console.log err


module.service 'imgurService', require './imgurService.coffee'

module.directive 'ngFilePaste', ($parse, $timeout) ->
  restrict: 'A'
  link: ($scope, element, attrs) ->
    fn = $parse attrs.ngFilePaste
    document.onpaste = (event) ->
      items = (event.clipboardData || event.originalEvent.clipboardData).items

      # Map all items to data url's
      async.map items, (item, callback) ->
        blob = item.getAsFile()
        fileReader = new FileReader()
        fileReader.onload = (evt) ->
          callback null, evt.target.result
        fileReader.readAsDataURL(blob)

      , (err, results) ->
        $timeout ->
          fn $scope,
            $files: results,
            $event: event

    $scope.$on '$destroy', ->
      document.onpaste = null


module.filter 'thumbnail', () -> (val) ->
  basename = path.basename val, path.extname(val)
  val.replace basename, basename + 'b'

module.controller 'loginController', require('./loginController.coffee')
module.controller 'signupController', require('./signupController.coffee')
module.controller 'uploadController', require('./uploadController.coffee')

headerCtrl = ($scope, $modal, userService, $rootScope) ->
  $scope.auth = userService.auth

  $rootScope.$on '$firebaseSimpleLogin:login', ->
    $scope.user = userService.users.$child $scope.auth.user.id

  $scope.logout = ->
    @auth.$logout()

module.controller 'headerCtrl', headerCtrl

module.config ($routeProvider, $locationProvider, $modalProvider) ->
  $locationProvider.html5Mode true

  $routeProvider
    .when '/',
      templateUrl: '/partials/main/index.html'
      controller: ($scope, userService, fileService, $firebase) ->
        $scope.files = $firebase fileService.files

    .when '/files/:id',
      templateUrl: '/partials/file/index.html'
      controller: ($scope, $routeParams, userService, fileService, $firebase, $location) ->
        $scope.auth = userService.auth

        $scope.delete = ->
          @file.$remove().then () ->
            $location.path '/'

        $scope.file = $firebase(fileService.files).$child($routeParams.id)

        $scope.file.$on 'loaded', ->
          unless $scope.file.user_id?
            return $location.path '/404'
          user = userService.users.$child $scope.file.user_id
          user.$bind($scope, 'user')
