module Server.Shell.Persistence.MySQL where

import Prelude
import Effect (Effect)
import Effect.Class (liftEffect)
import MySQL.Connection (defaultConnectionInfo)
import MySQL.Pool (Pool, createPool, defaultPoolInfo)
import Server.Shared.Types as T
import Server.Shell.Interface.Persistence (Config(..), Handle(..))

mkHandle :: Config -> Effect Handle
mkHandle config = do
  pool <- createPool' config
  pure $ Handle { pool: T.MySQL pool }

createPool' :: Config -> Effect Pool
createPool' (Config c) = createPool connInfo defaultPoolInfo
  where
  connInfo =
    defaultConnectionInfo
      { host = c.host
      , database = c.database
      , user = c.user
      , password = c.password
      }

