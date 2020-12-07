module SimpleService.Server (runServer) where

import Prelude
import Data.Int (fromString)
import Data.Maybe (fromMaybe)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (Error, message)
import MySQL.Connection (defaultConnectionInfo)
import MySQL.Pool (Pool, createPool, defaultPoolInfo)
import Node.Express.App (App, delete, get, listenHttp, post, setProp, useExternal, useOnError)
import Node.Express.Handler (Handler)
import Node.Express.Response (sendJson, setStatus)
import Node.HTTP (Server)
import Node.Process (lookupEnv)
import SimpleService.Handler (createUser, deleteUser, getUser, listUsers, updateUser)
import SimpleService.Middleware.BodyParser (jsonBodyParser)

createPool' :: Effect Pool
createPool' = createPool connInfo defaultPoolInfo
  where
  connInfo =
    defaultConnectionInfo
      { host = "localhost"
      , database = "simple_service"
      , user = "a"
      , password = "password"
      }

errorHandler :: Error -> Handler
errorHandler err = do
  setStatus 400
  sendJson { error: message err }

appSetup :: Pool -> App
appSetup pool = do
  useExternal jsonBodyParser
  liftEffect $ log "Setting up"
  setProp "json spaces" 4.0
  get "/v1/user/:id" $ getUser pool
  get "/v1/users" $ listUsers pool
  delete "/v1/user/:id" $ deleteUser pool
  post "/v1/users" $ createUser pool
  post "/v1/user/:id" $ updateUser pool
  useOnError (errorHandler)

parseInt :: String -> Int
parseInt str = fromMaybe 0 $ fromString str

runServer :: Effect Server
runServer = do
  pool <- liftEffect createPool'
  port <- (parseInt <<< fromMaybe "4000") <$> lookupEnv "PORT"
  listenHttp (appSetup pool) port \_ ->
    log $ "Listening on " <> show port

