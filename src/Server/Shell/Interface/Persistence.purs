module Server.Shell.Interface.Persistence where

import Server.Shared.Types (Pool)

data Config
  = Config
    { host :: String
    , database :: String
    , user :: String
    , password :: String
    }

data Handle
  = Handle { pool :: Pool }

