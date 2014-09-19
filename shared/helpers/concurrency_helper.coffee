Promise = require 'bluebird'

exports.Semaphore = class Semaphore
  constructor: (slots) ->
    @slots = @maxSlots = slots
    @queue = []
    @_finished = null

  pop: ->
    @slots += 1
    next = @queue.shift()
    @enter.apply this, next if next
    
    if @slots == @maxSlots and @_finished?
      _finished = @_finished
      @_finished = null
      _finished.resolve()

  push: (func) ->
    if @slots > 0
      @enter func
    else
      deferred = Promise.defer()
      @queue.push [func, deferred]
      deferred.promise

  enter: (func, deferred) ->
    @slots -= 1
    Promise.when(func()).then (ret) =>
      deferred.resolve ret if deferred
      @pop()
      ret
    .catch (reason) =>
      deferred.reject reason if deferred
      @pop()
      reason

  finished: ->
    if @slots == @maxSlots
      console.log 'Semaphore.finished: finishing early'
      return Promise.when {}

    @_finished = Promise.defer() unless @_finished
    @_finished.promise