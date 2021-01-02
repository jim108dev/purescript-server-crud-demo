module Main where

import Prelude

import Data.Int (fromString)
import Data.Maybe (fromMaybe)
import Effect (Effect)
import Effect.Console (log)
import Node.Express.App (listenHttp)
import Node.HTTP (Server)
import Node.Process (lookupEnv)
import Payload.Server as Payload
import Server.Shell.Api.Express (manageRequests)
import Server.Shell.Api.Payload as ShellApi
import Server.Shell.Interface.Persistence (Config(..))
import Server.Shell.Persistence.Mock as Mock
import Server.Shell.Persistence.MySQL as MySQL

parseInt :: String -> Int
parseInt str = fromMaybe 0 $ fromString str

config :: Config
config =
  Config
    { host: "localhost"
    , database: "a_database"
    , user: "a"
    , password: "password"
    }

runServerExpressMock :: Effect Server
runServerExpressMock = do
  handle <- pure Mock.mkHandle
  port <- (parseInt <<< fromMaybe "3000") <$> lookupEnv "PORT"
  listenHttp (manageRequests handle) port \_ ->
    log $ "Listening on " <> show port

runServerExpressMySQL :: Effect Server
runServerExpressMySQL = do
  handle <- MySQL.mkHandle config
  port <- (parseInt <<< fromMaybe "3000") <$> lookupEnv "PORT"
  listenHttp (manageRequests handle) port \_ ->
    log $ "Listening on " <> show port

runServerPayloadMySQL :: Effect Unit
runServerPayloadMySQL = do
  handle <- MySQL.mkHandle config
  Payload.launch ShellApi.spec $ ShellApi.handlers handle

main :: Effect Unit
main = runServerPayloadMySQL

