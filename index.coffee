system    = require 'system'
webpage   = require 'webpage'
viewports = require './viewports.json'
Q         = require 'q'
cartesianProduct = require './cartesian.coffee'

args = system.args
site = args[1]
filename = args[2]

asRendering = (viewport, orientation) ->
  return null unless orientation in ["Landscape", "Portrait"]

  filename = viewport["Device Name"].replace /\s/g, '_'
  altOrientation = if orientation == "Landscape" then "Portrait" else "Landscape"

  {
    device: viewport["Device Name"]
    filename: "#{filename}_#{orientation}"
    width: viewport["#{orientation} Width"]
    height: viewport["#{altOrientation} Width"]
    orientation: orientation
  }

render = (rendering) ->
  deferred = Q.defer()

  fullpath  = "./tmp/#{rendering.filename}.png"

  page.viewportSize = page.clipRect =
    width: rendering.width
    height: rendering.height

  page.open site, () ->
    page.render fullpath
    console.log "Rendering #{site} on #{rendering.device} in #{rendering.orientation} to fullpath"
    deferred.resolve
      filename: fullpath
      device: rendering.device
      orientation: rendering.orientation

  deferred.promise

reduceRender = (agg, next) ->
  agg.then (result) ->
    render(next)

# just use iOS for now
viewports = viewports.filter (viewport) ->
  viewport["Platform"].indexOf("iOS") == 0

page = webpage.create()
cartesianProduct(['Landscape', 'Portrait'], viewports)
  .map((product) -> asRendering product[1], product[0])
  .reduce(reduceRender, Q())
  .catch () ->
    page.close()
    phantom.exit()
  .done () ->
    page.close()
    phantom.exit()
