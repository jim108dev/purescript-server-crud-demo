module Server.Shell.Persistence.Mock where

import Prelude
import Effect (Effect)
import Server.Shared.Types (Pool(..))
import Server.Shell.Interface.Persistence (Config, Handle(..))

--makeHandle :: Config -> Effect Handle
--makeHandle _ = pure $ Handle { pool: None }
makeHandle :: Config -> Effect Handle
makeHandle _ = pure $ Handle { pool: None }

