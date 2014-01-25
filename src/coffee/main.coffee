_           = require 'underscore'
path        = require 'path'
angular     = require 'angular'
ngRoute     = require 'angular-route'
bootstrap   = require 'angular-ui'
md5         = require 'angular-md5'
gravatar    = require 'angular-gravatar'
templates   = require 'angular-ui-templates'
Firebase    = require 'firebase'
angularfire = require 'angularfire'
SimpleLogin = require 'firebase-simple-login'
ngFileUpload = require 'ng-file-upload'

module = angular.module 'app', [
  'ngRoute'
  'firebase'
  'ui.bootstrap'
  'ui.gravatar'
  'angularFileUpload'
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
        console.log _.omit(userData, 'password')
        users.$child(user.id).$set _.omit(userData, 'password')
      , (err) ->
        console.log err


module.service 'imgurService', require './imgurService.coffee'


module.filter 'thumbnail', () -> (val) ->
  basename = path.basename val, path.extname(val)
  val.replace basename, basename + 'b'

headerCtrl = ($scope, $modal, userService, $rootScope) ->
  $scope.auth = userService.auth

  $rootScope.$on '$firebaseSimpleLogin:login', ->
    $scope.user = userService.users.$child $scope.auth.user.id

  $scope.login = ->
    $modal.open
      templateUrl: '/partials/login.html'
      controller: require('./loginController.coffee')

  $scope.logout = ->
    @auth.$logout()

  $scope.signup = ->
    $modal.open
      templateUrl: '/partials/signup.html'
      controller: require('./signupController.coffee')

  $scope.upload = ->
    $modal.open
      templateUrl: '/partials/upload.html'
      controller: require('./uploadController.coffee')



module.controller 'headerCtrl', headerCtrl

module.config ($routeProvider, $locationProvider) ->
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


module.directive 'fileInput', ($parse) ->
  restrict: 'A'
  link: ($scope, element, attrs) ->
    modelGet = $parse attrs.fileInput
    modelSet = modelGet.assign
    onChange = $parse attrs.onChange

    updateModel = ->
      $scope.$apply ->
        modelSet $scope, element[0].files[0]
        onChange($scope)

    element.on 'change', updateModel
