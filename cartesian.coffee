_ = require 'lodash'

module.exports = () ->
  _.reduce(arguments, (a, b) ->
    _.flatten(_.map(a, (x) ->
      _.map(b, (y) ->
        x.concat([y])
      )
    ), true)
  , [ [] ])
