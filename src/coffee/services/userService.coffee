config = require '../config.coffee'

module.exports = (FirebaseService, $firebase, $firebaseSimpleLogin, $q) ->
  deferred = $q.defer()

  usersRef = new Firebase config.firebase.address + 'users'

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
