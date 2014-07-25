

Adapter = require "null-authorization-adapter"

class JSONAdapter extends Adapter
  name: "json"

  initialize: (options) =>
    @options = options

    @_resources = options.resources
    @_permissions = options.permissions
    @_acls = options.acls


  loadResources: (resources) =>
    @_resource = resources
    @

  loadPermissions: (permissions) =>
    @_permissions = permissions
    @

  loadACLs: (acls) =>
    @_acls = acls
    @

  findResource: (name) =>
    return @_resource[name]

  findPermission: (permission) =>
    return @_permissions[permission]

  findACL: (acl) =>
    return @_acls[acl]

module.exports = JSONAdapter
