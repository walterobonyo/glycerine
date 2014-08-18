Glycerine = require('..')

describe 'Glycerine', ->
  describe 'constructor', ->
    it 'should allow an API key to be supplied via a string', ->
      key = 'abcdef'
      g   = new Glycerine(key)
      expect(g.key).to.eql(key)

    it 'should allow an API key to be supplied via an object', ->
      key = 'abcdef'
      g   = new Glycerine(key: key)
      expect(g.key).to.eql(key)

    it 'should raise GlycerineNoCredentialsError if no API key is supplied', ->
      expect(->
        new Glycerine()
      ).to.throw()
