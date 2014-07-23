_ = require "underscore"

acls_obj =
  "is_admin": "subject.is_admin == false"
  "is_owner": "subject._id != resource._id"
  "is_user": "subject._id != resource._id"
  "user_denny": "subject._id == resource._id"
  "is_auth": "subject._id != resource._id"

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
    allow_acls = []
    denny_acls = []
    acl_validation = []
    for acl in acls
      allow_acl = @defaultPolicy unless acl.allow?
      denny_acl = not @defaultPolicy unless acl.allow?

      allow_acl = @_validate(acl.allow) if acl.allow?
      denny_acl = @_validate(acl.denny) if acl.denny?

      # allow_acls.push allow_acl if allow_acl?
      # denny_acls.push denny_acl if denny_acl?


      if denny_acl? and allow_acl?
        # operation
        # X ⊄ Y = Converse Nonimplication = !X AND Y, NOT(X OR !Y), (X XOR Y) AND Y, ???
        x = denny_acl
        y = allow_acl

        policy = not x and y

      else if denny_acl?
        policy = denny_acl
      else if allow_acl?
        policy = allow_acl
      else
        policy = @defaultPolicy

      res = {
        access: acl.access
        result: policy
      }
      acl_validation.push res

      if policy
        result = res
        break

    unless result
      result =
        access: null
        result: false

    console.log "RESULT: ", result
    return callback(result)


  _validate: (rules) =>
    validate = (if rules instanceof Array then "_arrayValidate" else "_#{typeof rules}Validate")

    if @[validate]?
      result = @[validate](rules)
    else
      result = @_defaultValidate(rules)

    return result


  _defaultValidate: (acls) =>
    # default validator
    return @defaultPolicy

  _stringValidate: (acl) =>
    # validator when acls statement is just string.
    # ex: allow: "is_admin"

    current_acl = acls_obj[acl]

    return @defaultPolicy unless current_acl?

    subject = @subject
    resource = @resource
    options = @options
    result = eval(current_acl)
    console.log "ACL policy: ", acl, result
    return  result

  _arrayValidate: (acls, operator = "$and") =>
    # validator when acls statement is an array.
    # ex: allow: ["is_admin", "is_owner"]
    result = _.reduce acls, (start, acl) =>
      acl_result = @_stringValidate(acl)

      switch @operators[operator].operation
        when "and"
          return start and acl_result
        when "or"
          return start or acl_result
        else
          return acl_result

    , @operators[operator].startValue

    return result

  _objectValidate: (acls) =>
    # validator when acls statement is an object.
    # ex: allow: { $and: ["is_admin", "is_owner"] }

    results = []
    for key, value of acls
      operator = key
      rules = value
      validate = (if rules instanceof Array then "_arrayValidate" else "_#{typeof rules}Validate")

      if @[validate]? and operator in Object.keys(@operators)
        results.push @[validate](rules, operator)
      else
        results.push @_defaultValidate(rules)

    return _.reduce results, (start, result) =>
      return result and start
    , yes

module.exports = ACL
