permissions = {
  "User:read": [{
    access: "all"
    allow:
      "$or": ["is_admin", "is_owner"]
    denny: "user_denny"
  },
  {
    access: "email username"
    allow:
      "$or": ["is_auth"]
    denny: "is_anonimous"
  },
  {
    access: "-password"
    allow: ["is_user"]
    denny: "is_anonimous"
  }]
}

class Permisssion

  find: (perm, cb) =>
    policy = permissions[perm]
    return cb( null, policy) if policy?
    return cb(null, false)


module.exports = new Permisssion()
