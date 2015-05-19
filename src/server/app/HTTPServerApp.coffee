App               = require './../../common/app/App'
HTTPServer        = require './../server/http/HTTPServer'
Compress          = require './../server/http/Compress'
SlashRedirector   = require './../server/http/SlashRedirector'
StaticController  = require './../server/http/StaticController'


##
# The App class is a special-case controller.
#
# @class ServerApp
# @extends App

module.exports = class HTTPServerApp extends App

  ##
  # ServerApp constructor.
  #
  # @param {object} [opts] - Options object.
  #
  # @param {boolean} [opts.compress=true] - Set to `true` to enable automatic
  # gzip or deflate compression.
  #
  # @constructor

  constructor: (opts = {}) ->

    super 'log'

    opts.compress ?= true
    opts.stripTrailingSlash ?= true

    ##
    # Internal HTTPServer.
    #
    # @property _server
    # @public

    @server = new HTTPServer

    if opts.stripTrailingSlash
      @server._pre new SlashRedirector

    if opts.compress
      @server._post new Compress


  ##
  # Creates and returns a new StaticController object setup to serve content
  # from the passed `serveDir`.
  #
  # @param {string} serveDir - Directory from-which to serve static content.
  # Should be relative to the current working directory.
  #
  # @return {StaticController} StaticController object setup to serve content
  # from the passed directory.
  #
  # @method static
  # @public

  static: (serveDir) ->
    new StaticController @, serveDir
