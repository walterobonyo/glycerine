request = require('request')
url     = require('url')
_       = require('lodash')

{
  GlycerineNoCredentialsError,
  GlycerineAPIError,
  GlycerineHTTPError,
  GlycerineResourceNotFoundError
} = require('./errors')

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
      "You must supply a Nitro API key to Glycerine's constructor in some way."
    ) unless @key

  resource: (resourceName, options, done) ->
    if typeof options isnt 'object'
      done = options
      options = {}

    @_retrieveResources (err, resources) =>
      return done(err) if err

      resource = _.find(resources.feeds.feed, name: resourceName)

      unless resource
        return done(new GlycerineResourceNotFoundError("Can't find #{resourceName}"))

      @resourceFromHref(resource.href, options, done)

  resourceFromHref: (href, options, done) ->
    @_makeRequest href, options, (err, resource) =>
      return done(err) if err

      done(null, @_formatResourceObject(resource.nitro))

  _formatResourceObject: (resource) ->
    format = (object) =>
      for key, value of object
        if typeof value is 'object' and value.href
          object[key] = (done) =>
            @resourceFromHref(value.href, done)
        else if typeof value is 'object' or typeof value is 'array'
          object[key] = format(value)

      object

    format(resource)

  _retrieveResources: (done) ->
    return done(null, @_resources) if @_resources

    @_makeRequest '/nitro/api', {}, (err, resources) =>
      return done(err) if err

      @_resources = resources
      done(null, @_resources)

  _makeRequest: (endpoint, options, done) ->    
    options =
      url: @_urlFor(endpoint, options)
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

  _urlFor: (endpoint, options) ->
    resourceURL = url.parse("http://#{@host}#{endpoint}", true)
    resourceURL.query.api_key = @key
    resourceURL.query = _.assign(resourceURL.query, options)
    delete resourceURL.search
    url.format(resourceURL)

module.exports = Glycerine
