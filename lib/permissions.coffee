permissions = {
	"User:read":
	  allow: [
	  	{
	  	  access: "all"
	  	  rules:
	  	  	"$or": ["is_admin", "is_owner"]
	  	}
	  	{
	  		access: "-password"
	  		rules: ["is_user"]
	  	}
	  ]
	  denny: [
	  	{
	  		access: "all"
	  		rules: "user_denny"
	  	}
	  ]
}

class Permisssion

	find: (perm, cb) =>
		console.log perm, permissions, permissions[perm]
		return cb( null, permissions[perm])


module.exports = new Permisssion()