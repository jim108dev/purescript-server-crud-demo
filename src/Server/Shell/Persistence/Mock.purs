module Server.Shell.Persistence.Mock where

import Server.Shared.Types (Pool(..))
import Server.Shell.Interface.Persistence (Handle(..))

mkHandle :: Handle
mkHandle = Handle { pool: None }

