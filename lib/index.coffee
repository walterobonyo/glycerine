url = require('url')

{GlycerineNoCredentialsError} = require('./errors')

class Glycerine
  key: null
  host: 'nitro.stage.api.bbci.co.uk'

  constructor: (options) ->
    if typeof options is 'string'
      @key = options
    else if typeof options is 'object'
      @key = options.key

    throw new GlycerineNoCredentialsError(
      'You must supply a Nitro API key to Glycerine\'s constructor in some way.'
    ) unless @key

  retrieveResources: ->
    @_makeRequest '/nitro/api', (response) ->
      console.log response

  _makeRequest: (endpoint) ->
    console.log @_urlFor(endpoint)

  _urlFor: (endpoint) ->
    resourceURL = url.parse("http://#{@host}#{endpoint}", true)
    resourceURL.query.api_key = @key
    url.format(resourceURL)

module.exports = Glycerine
