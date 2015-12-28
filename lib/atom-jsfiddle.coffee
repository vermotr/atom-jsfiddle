{CompositeDisposable} = require 'atom'
touch = require 'touch'
request = require 'request'
parser = require 'json-parser'
open = require 'open'

module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-jsfiddle:start': => @start()
      'atom-jsfiddle:upload': => @upload()

  deactivate: ->
    @subscriptions.dispose()

  start: ->
    extensions = ['html', 'css', 'js']

    atomPath = atom.project.getPaths()[0]
    if atomPath
      path = atomPath
    else
      path = '/tmp'
    for extension in extensions
      filename = path + '/jsFiddle.' + extension
      try
        touch filename
        console.log 'Create ' + filename
        atom.workspace.open filename
      catch error
        console.error error.message

  encodeParam: (data) ->
    ret = []
    for d of data
      ret.push encodeURIComponent(d) + '=' + encodeURIComponent(data[d])
    ret.join '&'

  upload: ->
    console.log 'Upload to jsFiddle'
    formData = {
      title: "jsFiddle from atom"
      description: 'An atom package to upload his code to jsFiddle.'
    }

    currentItems = atom.workspace.getPaneItems()
    for item in currentItems
      titleInfo = item.getTitle().split('.')
      if titleInfo[0] == 'jsFiddle' and titleInfo[1]
        switch titleInfo[1]
          when 'html' then formData.html = item.getText()
          when 'css' then formData.css = item.getText()
          when 'js' then formData.js = item.getText()

    request.post {
      url: 'http://atomjsfiddle.vermot.eu/library/pure/'
      formData: formData
    }, (err, httpResponse, body) ->
      if err
        console.error 'Post request failed: ' + err
      else
        result = parser.parse(body)
        console.log result.url
        open result.url
