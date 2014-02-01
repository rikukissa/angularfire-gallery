_ = require 'underscore'

module.exports = ($rootScope, $q, $firebaseSimpleLogin, FirebaseService) ->

  users: FirebaseService.child('users')

  auth: $firebaseSimpleLogin FirebaseService

  authenticate: (email, password) ->
    @auth.$login 'password',
      email: email
      password: password
    .then (user) =>
      @getUser()

  getUser: ->
    @auth.$getCurrentUser().then (user) ->
      deferred = $q.defer()
      unless user?
        err = new Error 'User not logged in'
        err.code = 'NOT_LOGGED_IN'
        deferred.reject err
        return deferred.promise

      userRef = FirebaseService.child('users').child user.id

      userRef.on 'value', (snapshot) ->
        deferred.resolve _.extend snapshot.val(), id: user.id

      , -> # User is not accepted
        err = new Error 'User not accepted'
        err.code = 'USER_NOT_ACCEPTED'
        deferred.reject err

      deferred.promise

  create: (userData) ->
    @auth
      .$createUser(userData.email, userData.password)

      .then (user) =>
        @users.child(user.id).set _.omit(userData, 'password')
      , (err) ->
        throw err

