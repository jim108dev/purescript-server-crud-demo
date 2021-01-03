module Main where

import Prelude

import Data.Int (fromString)
import Data.Maybe (fromMaybe)
import Dotenv (loadFile) as Dotenv
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
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

runServerExpressMock :: Effect Server
runServerExpressMock = do
  handle <- pure Mock.mkHandle
  port <- (parseInt <<< fromMaybe "3000") <$> lookupEnv "PORT"
  listenHttp (manageRequests handle) port \_ ->
    log $ "Listening on " <> show port

runServerExpressMySQL :: Config -> Effect Server
runServerExpressMySQL config = do
  handle <- MySQL.mkHandle config
  port <- (parseInt <<< fromMaybe "3000") <$> lookupEnv "PORT"
  listenHttp (manageRequests handle) port \_ ->
    log $ "Listening on " <> show port

runServerPayloadMySQL :: Config -> Effect Unit
runServerPayloadMySQL config = do
  handle <- MySQL.mkHandle config
  Payload.launch ShellApi.spec $ ShellApi.handlers handle

readConfig :: Effect Config
readConfig = do
  dbHost <- fromMaybe "" <$> lookupEnv "DB_HOST"
  dbDatabase <- fromMaybe "" <$> lookupEnv "DB_DATABASE"
  dbUser <- fromMaybe "" <$> lookupEnv "DB_USER"
  dbPassword <- fromMaybe "" <$> lookupEnv "DB_PASSWORD"
  pure
    $ Config
        { host: dbHost
        , database: dbDatabase
        , user: dbUser
        , password: dbPassword
        }

main :: Effect Unit
main =
  launchAff_ do
    _ <- Dotenv.loadFile
    liftEffect do
      config <- readConfig
      runServerPayloadMySQL config

