authorization = require("null-authorization")

JSONAdapter = authorization.adapters.JSONAdapter

resources = ["User"]

permissions = {
  "User:read": [{
    access: ["email", "username"]
    allow:
      "$or": ["is_admin", "is_owner"]
    deny: "user_deny"
  },
  {
    access: "all"
    allow:
      "$or": ["is_admin", "is_owner"]
    deny: "user_deny"
  },
  {
    access: "email username"
    allow:
      "$or": ["is_auth"]
    deny: "is_anonimous"
  },
  {
    access: "-password"
    allow: ["is_user"]
    deny: "is_anonimous"
  }]
}

acls =
  "is_admin": "subject.is_admin == true"
  "is_owner": "subject._id == resource._id"
  "is_user": "subject._id != resource._id"
  "user_deny": "subject._id != resource._id"
  "is_auth": "subject._id != resource._id"

options = {
  resources: resources
  permissions: permissions
  acls: acls
}

authorization.use(new JSONAdapter(options))

module.exports = authorization
