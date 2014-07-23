consider = require("./consider")
ACL = require("./acl")
Permission = require("./permissions")

class EnsureRequest
  constructor: (options) ->
    options = options or {}
    @options =
      withSubject: options.withSubject
      withPermissions: options.withPermissions
      redirectTo: options.returnTo or "/login"
      onDenied: options.onDenied

  withSubject: (getSubject) =>
    @options.withSubject = getSubject
    return @

  withPermissions: (getPermissions) =>
    @withPermissions = getPermissions
    @

  redirectTo: (url) =>
    @options.redirectTo = url
    @

  onDenied: (deny) =>
    @options.onDenied = deny
    @

  isPermitted: => # permission ... or [permission, ...] or permission check function

    arguments_ = arguments
    # Determine the permission check.
    withPermissionsDefault = (req, res) ->
      return req.user.permissions  if req.user and req.user.permissions
      return req.session.user.permissions  if req.session and req.session.user and req.session.user.permissions
      return req.permissions  if req.permissions
      []

    # Convert synchronous with function to asynchronous
    onDeniedDefault = (req, res, next) ->
      res.redirect redirectTo

    withSubject = @options.withSubject
    withPermissions = @options.withPermissions
    redirectTo = @options.redirectTo
    onDenied = @options.onDenied
    isPermittedCheck = undefined

    if arguments_.length is 1 and typeof (arguments_[0]) is "function"
      isPermittedCheck = arguments_[0]
    else
      permissions = arguments_
      isPermittedCheck = (claim) ->
        claim.isPermitted.apply claim, permissions

    considerFunction = (if withSubject then consider.considerSubject else consider.considerPermissions)

    withFunctionCandidate = (if withSubject then withSubject else withPermissions or withPermissionsDefault)
    withFunction = withFunctionCandidate

    unless withFunction.length is 3
      withFunction = (req, res, done) ->
        done withFunctionCandidate(req, res)

    onDeniedFunction = onDenied or onDeniedDefault

    return (req, res, next) ->
      withFunction req, res, (permissionsOrSubject) ->
        if isPermittedCheck(considerFunction(permissionsOrSubject))
          req.authorizer = @isAuthorized
          next()
        else
          onDeniedFunction req, res, next

  isAuthorized: (permission, subject, resource, options, callback) =>
    # 1. Default: Deny
    # 2. Evaluate applicable policies
    #      Match on: resource and action
    # 3. Does policy exist for resource and action?
    #      If no: Deny
    # 4. Do any rules resolve to Deny?
    #      If yes, Deny
    #      If no, Do any rules resolve to Allow?
    #      If yes, Allow
    #      Else: Deny
    Permission.find permission, (err, res) =>
      return callback(false) unless res
      acl = new ACL({subject: subject, resource: resource, options: options})

      acl.validate(res, (result) =>
        callback(result)
      )



module.exports = module.exports = new EnsureRequest()
module.exports.EnsureRequest = EnsureRequest
