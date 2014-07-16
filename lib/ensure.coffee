EnsureRequest = (options) ->
  options = options or {}
  @options =
    withSubject: options.withSubject
    withPermissions: options.withPermissions
    redirectTo: options.returnTo or "/login"
    onDenied: options.onDenied

consider = require("./consider")

EnsureRequest::withSubject = (getSubject) ->
  link = new EnsureRequest(@options)
  link.options.withSubject = getSubject
  link

EnsureRequest::withPermissions = (getPermissions) ->
  link = new EnsureRequest(@options)
  link.options.withPermissions = getPermissions
  link

EnsureRequest::redirectTo = (url) ->
  link = new EnsureRequest(@options)
  link.options.redirectTo = url
  link

EnsureRequest::onDenied = (deny) ->
  link = new EnsureRequest(@options)
  link.options.onDenied = deny
  link

EnsureRequest::isPermitted = -> # permission ... or [permission, ...] or permission check function

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
  (req, res, next) ->
    withFunction req, res, (permissionsOrSubject) ->
      if isPermittedCheck(considerFunction(permissionsOrSubject))
        next()
      else
        onDeniedFunction req, res, next


exports = module.exports = new EnsureRequest()
exports.EnsureRequest = EnsureRequest
