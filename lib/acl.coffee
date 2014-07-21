_ = require "underscore"

acls_obj =
	"is_admin": "subject.is_admin == true"
	"is_owner": "subject._id == resource._id"
	"is_user": "subject._id != resource._id"
	"user_denny": "subject._id != resource._id"

class ACL
	constructor: (options) ->
		@subject = options.subject
		@resource = options.resource
		@options =  options.options

		@defaultPolicy = options.defaultPolicy | no

	operators:
		"$and":
		  startValue: yes
		  operator: "and"
		"$or":
		  startValue: no
		  operator: "or"
		"$not":
		  startValue: null
		  operator: "not"

	validate: (acls, callback) =>
		allow_acls = @_validate(acls.allow)  if acls.allow?
		denny_acls = @_validate(acls.denny) if acls.denny?

		console.log "ACLS ALLOW: ", allow_acls
		console.log "ACLS DENNY: ", denny_acls

		if denny_acls? and allow_acls?
			# operation
	    # X ⊄ Y = Converse Nonimplication = !X AND Y, NOT(X OR !Y), (X XOR Y) AND Y, ???
	    x = denny_acls
	    y = allow_acls

	    result = not x and y

	  else if denny_acls?
	  	result = denny_acls
	  else if allow_acls?
	  	result = allow_acls
	  else
	  	result = @defaultPolicy

	  return callback(result)


	_validate: (rules) =>
	  match = []
	  for rule in rules
	  	validate = (if rule.rules instanceof Array then "_arrayValidate" else "_#{typeof rule.rules}Validate")
	  	result = {
	  		access: rule.access
	  		result: @defaultPolicy
	  	}
	  	console.log "validation type: ", validate
	  	if @[validate]?
	  		result.result = @[validate](rule.rules)
	  	else
	  		result.result = @_defaultValidate(rule.rules)

	  	match.push result

	  return match


	_defaultValidate: (acls) =>
		# default validator
		return @defaultPolicy

	_stringValidate: (acl) =>
		# validator when acls statement is just string.
		# ex: allow: "is_admin"
		current_acl = acls_obj[acl]

		return @defaultPolicy unless current_acl

		subject = @subject
		resource = @resource
		options = @options
		return eval(current_acl)

	_arrayValidate: (acls, operator = "$and") =>
		# validator when acls statement is an array.
		# ex: allow: ["is_admin", "is_owner"]
		result = _.reduce acls, (start, acl) =>
			acl_result = @_stringValidate(acl)
			console.log "ACL value: ", acl_result
			switch @operators[operator].operation
				when "and"
					return start and acl_result
				when "or"
					return start or acl_result
				else
					return acl_result

		, @operators[operator].startValue

		console.log "ARRAY ACl valuetion: ", operator, acls, result
		return result

	_objectValidate: (acls) =>
		# validator when acls statement is an object.
		# ex: allow: { $and: ["is_admin", "is_owner"] }
		results = []
		for key, value of acls
			operator = key
			rules = value
			validate = (if rules instanceof Array then "_arrayValidate" else "_#{typeof rules}Validate")

			console.log "object validation type: ", validate, rules
			if @[validate]? and operator in Object.keys(@operators)
				results.push @[validate](rules, operator)
			else
				results.push @_defaultValidate(rules)

		return _.reduce results, (start, result) =>
			return result and start
		, yes

module.exports = ACL







