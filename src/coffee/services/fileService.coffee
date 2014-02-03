_ = require 'underscore'
async = require 'async'

module.exports = ($q, FirebaseService, userService) ->
  files: FirebaseService.child('files')

  getFile: (id) ->
    deferred = $q.defer()

    # Search for file
    @files.child(id).once 'value', (snapshot) ->

      file = snapshot.val()

      unless file?
        return deferred.reject new Error "File #{id} not found"

      file.$priority = snapshot.getPriority()
      file.$name = snapshot.name()

      # Search for user
      userService.users.child(file.user_id).once 'value', (snapshot) ->
        file.user = snapshot.val()
        deferred.resolve file

    deferred.promise

  removeFile: (id) ->
    deferred = $q.defer()

    removeRef = @files.child(id).remove()

    @files.once 'child_removed', ->
      deferred.resolve()

    deferred.promise

  getPublicFiles: ->
    deferred = $q.defer()

    FirebaseService.child('public_files').on 'value', (snapshot) =>
      names = _.keys snapshot.val()

      return deferred.resolve [] if names.length is 0

      async.map names, (name, callback) =>
        @files.child(name).on 'value', (snapshot) ->
          callback null, snapshot.val()
        , callback
      , (err, results) ->
        return deferred.reject err if err?
        deferred.resolve results

    deferred.promise
