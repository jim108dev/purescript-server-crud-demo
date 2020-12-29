module Server.User.Interface.Persistence where

import Data.Maybe (Maybe)
import Effect.Aff (Aff)
import Server.User.Types (NewUser, User, UserId)

data Handle
  = Handle
    { findUser :: UserId -> Aff (Maybe User)
    , insertUser :: NewUser -> Aff (Maybe User)
    , updateUser :: User -> Aff (Maybe User)
    , deleteUser :: UserId -> Aff (Maybe User)
    , listUsers :: Aff (Array (User))
    }

