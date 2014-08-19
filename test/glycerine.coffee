Glycerine = require('../lib/glycerine')
{GlycerineNoCredentialsError, GlycerineAPIError, GlycerineHTTPError, GlycerineResourceNotFoundError} = require('../lib/errors')

describe 'Glycerine', ->
  describe 'constructor', ->
    it 'should allow an API key to be supplied via a string', ->
      key = 'abcdef'
      g   = new Glycerine(key)
      expect(g.key).to.eq(key)

    it 'should allow an API key to be supplied via an object', ->
      key = 'abcdef'
      g   = new Glycerine(key: key)
      expect(g.key).to.eq(key)

    it 'should allow a Nitro host to be supplied via an object', ->
      host = 'example.com'
      key  = 'abcdef'
      g    = new Glycerine(key: key, host: host)
      expect(g.host).to.eq(host)

    it 'should throw a GlycerineNoCredentialsError if no API key is supplied', ->
      expect(->
        new Glycerine()
      ).to.throw(GlycerineNoCredentialsError)

  describe '#resource', ->
    before ->
      @g = new Glycerine('AngZeAC95PmW9w6ClTp4Ymyxjj0jpwPw')

    it 'should return a resource if found', (done) ->
      @g.resource 'Programmes', (err, resource) ->
        expect(err).to.be.null
        expect(resource).to.be.an('object')
        done()

    it "should yield a GlycerineResourceNotFoundError if the resource can't be found", (done) ->
      @g.resource 'Baked Potatoes', (err) ->
        expect(err).to.be.an.instanceOf(GlycerineResourceNotFoundError)
        done()

    it 'should tolerate options', (done) ->
      @g.resource 'Programmes', mixin: 'images', (err, resource) ->
        expect(err).to.be.null
        expect(resource).to.be.an('object')
        done()

  describe '#_retrieveResources', ->
    before ->
      @g = new Glycerine('AngZeAC95PmW9w6ClTp4Ymyxjj0jpwPw')

    it 'should yield a list of resources'

  describe '#_makeRequest', ->
    beforeEach ->
      @g = new Glycerine('AngZeAC95PmW9w6ClTp4Ymyxjj0jpwPw')

    it 'should yield some data if it receives a 2xx status code', (done) ->
      @g._makeRequest '/nitro/api', {}, done

    it 'should yield a GlycerineAPIError if it gets a non-2xx status code with fault info', (done) ->
      @g._makeRequest '/oh/god/i/really/hope/this/is/invalid', {}, (err) ->
        expect(err).to.be.an.instanceOf(GlycerineAPIError)
        done()

    it 'should yield a GlycerineHTTPError if it gets a non-2xx status code without fault info', (done) ->
      @g.host = 'example.com'
      @g._makeRequest '/nope', {}, (err) ->
        expect(err).to.be.an.instanceOf(GlycerineHTTPError)
        done()

    it 'should yield a GlycerineHTTPError if a generic HTTP error is encountered', (done) ->
      @g.host = 'nonexistenthostname'
      @g._makeRequest '/nope', {}, (err) ->
        expect(err).to.be.an.instanceOf(GlycerineHTTPError)
        done()

  describe '#_urlFor', ->
    beforeEach ->
      @g = new Glycerine(key: 'abcdef', host: 'example.com')

    it 'should return a keyed up resource URL', ->
      expect(
        @g._urlFor('/foo/bar')
      ).to.eq('http://example.com/foo/bar?api_key=abcdef')

    it 'should preserve any existing query string data', ->
      expect(
        @g._urlFor('/foo/bar?bat=baz')
      ).to.eq('http://example.com/foo/bar?bat=baz&api_key=abcdef')
