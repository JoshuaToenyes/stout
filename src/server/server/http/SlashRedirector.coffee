##
# Defines HTTP middleware for generating trailing-slash redirects.
#
# @fileoverview

Middleware = require './../../../common/middleware/Middleware'


##
# HTTP middleware function to generate HTTP 301 redirects for URLs with
# trailing slashes.
#
# @class SlashRedirector

module.exports = class SlashRedirector extends Middleware

  constructor: ->

  ##
  #
  # @override
  # @public

  fn: (req, res, cb) ->

    p = req.url

    if p.pathname.length > 1 and p.pathname.match /\/$/

      # Remove trailing slash.
      redirectUrl = p.href.replace /\/$/, ''

      # Remove trailing slash before query string.
      redirectUrl = redirectUrl.replace /\/\?/, '?'

      res.permanentRedirect redirectUrl

      cb('trailing-slash redirect', req, res)
    else
      cb(null, req, res)
