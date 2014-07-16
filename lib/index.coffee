consider = require("./consider")
ensure = require("./ensure")
module.exports =
  considerSubject: consider.considerSubject
  considerPermissions: consider.considerPermissions
  ensureRequest: ensure
  EnsureRequest: ensure.EnsureRequest
