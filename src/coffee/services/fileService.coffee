_ = require 'underscore'
async = require 'async'

formatCollection = (snapshot, obj) ->
  for key, value of obj
    value.$name = key
    value.$priority = snapshot.child(key).getPriority()

module.exports = ($q, FirebaseService) ->
  files: FirebaseService.child('files')

  getNext: (priority, limit = 5) ->
    deferred = $q.defer()

    limit += 1

    @files.endAt(priority).limit(limit).once 'value', (snapshot) ->
      files = snapshot.val()

      formatCollection snapshot, files

      deferred.resolve _.toArray(files).reverse().slice(1)

    deferred.promise

  getPrevious: (priority, limit = 5) ->
    deferred = $q.defer()

    limit += 1

    @files.startAt(priority).limit(limit).once 'value', (snapshot) ->
      files = snapshot.val()
      formatCollection snapshot, files
      deferred.resolve _.toArray(files).slice(1)

    deferred.promise

  getFile: (id) ->
    deferred = $q.defer()

    # Search for file
    @files.child(id).once 'value', (snapshot) ->

      file = snapshot.val()

      unless file?
        return deferred.reject new Error "File #{id} not found"

      file.$priority = snapshot.getPriority()
      file.$name = snapshot.name()

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
