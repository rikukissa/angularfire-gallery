_ = require 'underscore'

module.exports = ($rootScope, $q, $firebaseSimpleLogin, FirebaseService) ->

  users: FirebaseService.child('users')

  auth: $firebaseSimpleLogin FirebaseService

  getUser: (id) ->
    deferred = $q.defer()

    @users.child(id).once 'value', (snapshot) ->
      user = snapshot.val()
      unless user?
        return deferred.reject new Error "User #{id} not found"
      deferred.resolve user

    deferred.promise

  authenticate: (email, password) ->
    @auth.$login 'password',
      email: email
      password: password
    .then (user) =>
      @getCurrentUser()

  getCurrentUser: ->
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

