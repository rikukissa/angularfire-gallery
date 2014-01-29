_ = require 'underscore'
config = require '../config.coffee'

module.exports = (FirebaseService, $firebaseSimpleLogin, $rootScope) ->

  usersRef = new Firebase config.firebase.address + 'users'

  service =
    user: null
    users: usersRef
    auth: $firebaseSimpleLogin FirebaseService
    create: (userData) ->
      @auth
        .$createUser(userData.email, userData.password)

        .then (user) =>
          @users.child(user.id).set _.omit(userData, 'password')
        , (err) ->
          throw err

  $rootScope.$on '$firebaseSimpleLogin:login', ->
    service.user = service.users.child service.auth.user.id

  $rootScope.$on '$firebaseSimpleLogin:logout', ->
    service.user = null

  service
