
/*
IDEAS

multi-parent

file child of:
  post - has attachments (files)
  user - has dp (file)

so:

  File:
    bytes
    created
    updated

  User:
    dp - File
  Post:
    attachments - [File]


another example:

  Company:
    owner - User
    employees - [User]
    reports - [Report]

  User:
    company - Company
    reports - [Report]
  
  Report
    assignedFrom - User
    assignedTo - User
    elements - [Element]
  
  Element
    type - [ElementType]
    

*/


var tranquil = require("../");

var server = tranquil.createServer({
  baseUrl: '/api',
  timestamps: true
});

server.addValidators({
  email: {
    validator: function(e) {
      return !!e.match(/@/);
    },
    msg: "yo missin da @ !"
  }
});

server.addUserResource({
  name: 'User',
  schema: {
    a: {
      type: String,
      validate: ['email']
    },
    b: Number,
    company: 'Company'
  },
  middleware: {
    post: {
      save: function(doc) {
        console.log("saved", doc);
      }
    }
  }
});

server.addResource({
  name: 'Company',
  schema: {
    c: String,
    d: Number,
    employees: ['User'],
    owner: 'User'
  },
  access: {
    c: {
      allow: 'admin'
    },
    r: true,
    u: ['admin', 'moderator'],
    d: false
  }
});

server.addResource({
  name: 'Report',
  schema: {
    e: String,
    f: Number,
    //posts have 1 forum
    //forum has many posts
    assignedBy: 'User',
    assignedTo: 'User'
  }
});

server.listen(1337);

