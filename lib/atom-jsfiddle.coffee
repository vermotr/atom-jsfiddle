{CompositeDisposable} = require 'atom'
touch = require 'touch'
{exec} = require('child_process')
Shell = require('shell')

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

  openPath: (filePath) ->
    process_architecture = process.platform
    switch process_architecture
      when 'darwin' then exec ('open "'+filePath+'"')
      when 'linux' then exec ('xdg-open "'+filePath+'"')
      when 'win32' then Shell.openExternal('file:///'+filePath)

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

    url = 'http://jsfiddle.vermot.eu/index.php?' + @encodeParam formData
    @openPath url
