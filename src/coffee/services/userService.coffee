_ = require 'underscore'



module.exports = ($rootScope, $q, $firebaseSimpleLogin, FirebaseService) ->
  class User
    constructor: (@$snapshot) ->
      @$name = @$snapshot.name()
      @[key] = value for key, value of $snapshot.val()
      @favourites ?= {}
      @files ?= {}

    $save: ->
      deferred = $q.defer()

      omittedKeys = ['$snapshot', '$name', '$save']

      userData = _.omit @, omittedKeys

      @$snapshot.ref().update userData, (err) ->
        deferred.reject err if err?
        deferred.resolve @

      deferred.promise

  users: FirebaseService.child('users')

  auth: $firebaseSimpleLogin FirebaseService

  getUser: (id) ->
    deferred = $q.defer()
    @users.child(id).once 'value', (snapshot) ->
      user = snapshot.val()
      unless user?
        err = new Error "User #{id} not found"
        err.code = 'USER_NOT_FOUND'
        return deferred.reject err
      deferred.resolve new User snapshot

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

      userRef.once 'value', (snapshot) ->
        deferred.resolve new User snapshot
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

