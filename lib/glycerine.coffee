request = require('request')
url     = require('url')

{GlycerineNoCredentialsError, GlycerineAPIError, GlycerineHTTPError} = require('./errors')

class Glycerine
  key: null
  host: null
  _resources: null

  constructor: (options) ->
    if typeof options is 'string'
      @key = options
    else if typeof options is 'object'
      @key  = options.key
      @host = options.host

    @host ||= 'nitro.stage.api.bbci.co.uk'

    throw new GlycerineNoCredentialsError(
      'You must supply a Nitro API key to Glycerine\'s constructor in some way.'
    ) unless @key    

  _retrieveResources: (done) ->
    done(null, @_resources) if @_resources

    @_makeRequest '/nitro/api', (err, resources) =>
      return done(err) if err

      @_resources = resources
      done(null, @_resources)

  _makeRequest: (endpoint, done) ->
    options =
      url: @_urlFor(endpoint)
      headers:
        Accept: 'application/json'
        'User-Agent': 'Glycerine'
      json: true
      strictSSL: true

    request options, (err, response, body) ->
      if err
        return done(new GlycerineHTTPError(err.message))

      if body.fault?.faultstring? and body.fault?.detail?.errorcode
        return done(new GlycerineAPIError("#{body.fault.faultstring} (#{body.fault.detail.errorcode})"))

      if response.statusCode isnt 200
        return done(new GlycerineHTTPError("HTTP #{response.statusCode}"))

      done(null, body)

  _urlFor: (endpoint) ->
    resourceURL = url.parse("http://#{@host}#{endpoint}", true)
    resourceURL.query.api_key = @key
    delete resourceURL.search
    url.format(resourceURL)

module.exports = Glycerine
