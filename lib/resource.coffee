# build rest actions
_ = require 'lodash'
mongoose = require 'mongoose'
require './schema-extend'
userify = require './userify'

#plugin variabless
unimplemented = (req, res) -> res.status 501

#define
class Resource
  
  defaults:
    idField: '_id'
    schemaOpts:
      strict: true
    middleware: {}

  #ENTRY
  constructor: (@name, @opts = {}, @rest) ->

    _.bindAll @

    unless _.isPlainObject @opts
      throw "Options must be a plain object"

    unless @opts.schema
      throw "Resource 'schema' required"

    _.defaults @opts, _.cloneDeep @defaults

    @routeName = @name.toLowerCase()
    @children = {}

  initialize: ->
    @checkOpts()
    @checkSchema()
    @defineSchema()
    @defineSchemaMiddleware()
    @defineRoute()
    console.log @name, "resource ready"
    
  #CONFIG
  checkOpts: ->
    if @opts.isUser
      userify @
      @rest.UserResource = @

  #SCHEMA
  checkSchema: ->

    #extract children
    for key, val of @opts.schema

      #array check
      isArray = _.isArray(val) and val.length is 1
      val = val[0] if isArray

      #link resource
      if typeof val is 'string'
        other = @rest.resources[val]
        if other and other.Schema
          @linkResource isArray, key, other
        else
          throw "#{@name} could NOT find: #{val}"

  linkResource: (isArray, field, other) ->

    #single
    unless isArray
      @opts.schema[field] = mongoose.Schema.ObjectId
      return

    #array
    #create routes on:
    #  /this/:id/field/:id/
    @opts.schema[field] = [mongoose.Schema.ObjectId]
    @children[field] = other

  defineSchema: ->

    #build mongoose schema
    if typeof @opts.extend is 'string'
      Extend = @rest.resources[@opts.extend]
      @Schema =  Extend.extend @opts.schema, @opts.schemaOpts
    else
      @Schema = new mongoose.Schema @opts.schema, @opts.schemaOpts
    
    #build mongoose model
    @Model = @rest.db.model @name, @Schema
    #back ref
    @Schema.resource = @

  defineSchemaMiddleware: ->
    set = (time, type, fn) =>
      if typeof fn is 'function'
        @Schema[time](type, fn)
        console.log @, "set middleware: #{time} #{type}"
    
    middleware = @opts.middleware

    for time, types of middleware
      for type, fns of types
        if typeof fns is 'array'
          for fn in fns
            set time, type, fn
        else
          set time, type, fns
    null

  #ROUTES
  defineRoute: (parent) ->
    #define this resource's routes
    routes = new Routes @, baseUrl, parent    
    #define child routes ontop
    for n, child of @children
      child.defineRoute routes


  #helpers
  toString: -> @name + ": "

module.exports = Resource
