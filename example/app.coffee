###
Module dependencies.
###
express = require("express")
http = require("http")
path = require("path")
authorization = require("../lib/")
app = express()

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", path.join(__dirname, "views")
app.set "view engine", "ejs"
app.use express.favicon()
app.use express.logger("dev")
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use express.cookieParser("your secret here")
app.use express.session()
app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

# setup permission middleware
console.log authorization.ensureRequest
ensureNounVerb = authorization.ensureRequest.isPermitted("noun:verb")


# Define Routes
app.get "/", (req, res) ->
  res.render "home",
    authenticated: (if req.session.user then true else false)


app.get "/login", (req, res) ->
  res.render "login", {}

app.post "/login", (req, res) ->
  req.session.user =
    username: "root"
    permissions: ["noun:*"]

  res.redirect "/"

app.get "/logout", (req, res) ->
  req.session.destroy()
  res.redirect "/"

app.get "/assert", ensureNounVerb, (req, res) ->
  res.render "assert", {}


# Start Server
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

