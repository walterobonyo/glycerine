class GlycerineError extends Error
  constructor: (message) ->
    @name = @.__proto__.constructor.name
    @message = "#{@name}: #{message}"

class GlycerineAPIError extends GlycerineError
class GlycerineHTTPError extends GlycerineError
class GlycerineNoCredentialsError extends GlycerineError
class GlycerineResourceNotFoundError extends GlycerineError
class GlycerineInvalidFilterError extends GlycerineError
class GlycerineInvalidMixinError extends GlycerineError
class GlycerineInvalidSortError extends GlycerineError

module.exports = {
  GlycerineAPIError,
  GlycerineHTTPError,
  GlycerineNoCredentialsError,
  GlycerineResourceNotFoundError,
  GlycerineInvalidFilterError,
  GlycerineInvalidMixinError,
  GlycerineInvalidSortError
}
