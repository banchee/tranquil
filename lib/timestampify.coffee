util = require "./util"

module.exports = (resource) ->

  console.log "timestampify!"

  #add user into into schema
  util.mixin resource.opts, {
    schema:
      createdAt:
        type: Date
        required: true

      updatedAt:
        type: Date
        required: true
    
    middleware:
      pre:
        validate: (next) -> 
          @updatedAt = new Date()
          next()
        
  }