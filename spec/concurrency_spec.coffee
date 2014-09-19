should = require 'should'
Promise = require 'bluebird'

{Semaphore} = require '../shared/helpers/concurrency_helper'

instrumentedDelay = ->
  instrumentedDelay.numRunning += 1
  Promise.delay(10).then ->
    instrumentedDelay.numRunning -= 1
    instrumentedDelay.numFinished += 1

instrumentedDelay.reset = ->
  instrumentedDelay.numRunning = 0
  instrumentedDelay.numFinished = 0

describe 'Semaphore', ->
  beforeEach -> instrumentedDelay.reset()

  it 'should be finished when empty', (success) ->
    new Semaphore(2).finished().then(-> success()).done()

  it 'should allow at most S jobs to run concurrently', (success) ->
    sem = new Semaphore 2

    sem.slots.should.equal 2
    
    sem.push(instrumentedDelay).done()
    sem.push(instrumentedDelay).done()
    sem.push(instrumentedDelay).done()

    sem.finished().then -> 
      instrumentedDelay.numRunning.should.equal 0
      instrumentedDelay.numFinished.should.equal 3
      success()

    sem.slots.should.equal 0
    instrumentedDelay.numRunning.should.equal 2