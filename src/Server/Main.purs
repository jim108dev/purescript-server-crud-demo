module Main where

import Prelude
import Data.Int (fromString)
import Data.Maybe (fromMaybe)
import Effect (Effect)
import Effect.Console (log)
import Node.Express.App (listenHttp)
import Node.HTTP (Server)
import Node.Process (lookupEnv)
import Server.Shell.Api.Main (manageRequests)
import Server.Shell.Interface.Persistence (Config(..))
import Server.Shell.Persistence.Mock as Mock
import Server.Shell.Persistence.MySQL as MySQL

parseInt :: String -> Int
parseInt str = fromMaybe 0 $ fromString str

config :: Config
config =
  Config
    { host: "localhost"
    , database: "simple_service"
    , user: "a"
    , password: "password"
    }

runServerMock :: Effect Server
runServerMock = do
  handle <- Mock.makeHandle config
  port <- (parseInt <<< fromMaybe "4000") <$> lookupEnv "PORT"
  listenHttp (manageRequests handle) port \_ ->
    log $ "Listening on " <> show port

runServer :: Effect Server
runServer = do
  handle <- MySQL.makeHandle config
  port <- (parseInt <<< fromMaybe "4000") <$> lookupEnv "PORT"
  listenHttp (manageRequests handle) port \_ ->
    log $ "Listening on " <> show port

main :: Effect Server
main = runServer

