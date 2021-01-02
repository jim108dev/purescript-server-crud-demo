module Test.MockApp where

import Prelude
import Data.Either (fromRight)
import Data.String (toUpper)
import Data.String.Regex (Regex, regex) as Re
import Data.String.Regex.Flags (noFlags) as Re
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (Error, message)
import Node.Express.App (App, all, setProp, use, useExternal, useOnError)
import Node.Express.Handler (Handler, next)
import Node.Express.Request (getMethod, getPath)
import Node.Express.Response (sendJson, setStatus)
import Partial.Unsafe (unsafePartial)
import Server.Shared.Api.Express (respond)
import Server.Shared.Types (Pool(..))
import Server.Shell.Api.BodyParser (jsonBodyParser)
import Server.Shell.Interface.Persistence (Handle(..))
import Server.User.Api.Express as UserApi
import Server.User.Persistence.Mock as UserMock
import Server.User.Persistence.MySQL as UserMySQL
import Shared.Util.Logger as Log

requestLogger :: Handler
requestLogger = do
  method <- getMethod
  path <- getPath
  Log.debug $ "HTTP: " <> (toUpper (show method)) <> " " <> path
  next

errorHandler :: Error -> Handler
errorHandler err = do
  setStatus 500
  sendJson { errors: [ message err ] }

allRoutePattern :: Re.Regex
allRoutePattern = unsafePartial $ fromRight $ Re.regex "/.*" Re.noFlags

manageRequests :: Handle -> App
manageRequests (Handle handle) = do
  useExternal jsonBodyParser
  use requestLogger
  liftEffect $ log "Setting up"
  setProp "json spaces" 4.0
  useOnError errorHandler
  all allRoutePattern $ respond 404 { errors: [ "Route not found" ] }

