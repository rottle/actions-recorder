
React = require("react")
Immutable = require("immutable")

recorder = require("./recorder")
updater = require("./updater")
schema = require './schema'
# testData = require './test.json'

require "origami-ui"
require "../style/main.css"

defaultInfo =
  initial: schema.store
  updater: updater
  inProduction: false

rawPersistent = localStorage.getItem("actions-recorder")
if rawPersistent
  try
    jsonPersistent = JSON.parse(rawPersistent)
    defaultInfo.initial = Immutable.fromJS(jsonPersistent.initial)
    defaultInfo.records = Immutable.fromJS(jsonPersistent.records)
    defaultInfo.pointer = jsonPersistent.pointer
    defaultInfo.isTravelling = jsonPersistent.isTravelling

# defaultInfo.initial = Immutable.fromJS(testData)
# defaultInfo.records = Immutable.fromJS([])

recorder.setup defaultInfo
if module.hot
  module.hot.accept ['./updater', './schema'], ->
    schema = require './schema'
    updater = require './updater'
    recorder.hotSetup
      initial: schema.store
      updater: updater

window.onbeforeunload = ->
  recorder.request (store, core) ->
    jsonPersistent =
      records: core.get('records').toJS()
      initial: core.get('initial').toJS()
      pointer: core.get('pointer')
      isTravelling: core.get('isTravelling')

    rawPersistent = JSON.stringify(jsonPersistent)
    localStorage.setItem "actions-recorder", rawPersistent


Page = React.createFactory(require("./app/page"))
render = (core) ->
  React.render Page({core}), document.body

recorder.request render
recorder.subscribe render
