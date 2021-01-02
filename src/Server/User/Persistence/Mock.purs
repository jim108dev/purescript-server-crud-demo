module Server.User.Persistence.Mock where

import Prelude
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Server.User.Interface.Persistence (Handle(..))
import Server.User.Types (NewUser(..), User(..), UserId)

mkHandle :: Handle
mkHandle =
  Handle
    { findUser: findUser
    , insertUser: insertUser
    , updateUser: updateUser
    , deleteUser: deleteUser
    , listUsers: listUsers
    }

findUserRightValue :: User
findUserRightValue = User { id: 1, name: "user" }

insertUserRightValue :: User
insertUserRightValue = User { id: 1, name: "userInserted" }

updateUserRightValue :: User
updateUserRightValue = User { id: 1, name: "userUpdated" }

deleteUserRightValue :: User
deleteUserRightValue = User { id: 1, name: "userDeleted" }

listUsersValue :: Array (User)
listUsersValue = [ User { id: 1, name: "user1" }, User { id: 2, name: "user2" } ]

maybeValue :: forall a. Boolean -> a -> Maybe a
maybeValue condition a =
  if condition then
    Just a
  else
    Nothing

findUser :: UserId -> Aff (Maybe User)
findUser userId = pure $ maybeValue (userId == 1) findUserRightValue

insertUser :: NewUser -> Aff (Maybe User)
insertUser (NewUser user) = pure $ maybeValue (user.name == "userInserted") insertUserRightValue

updateUser :: User -> Aff (Maybe User)
updateUser (User user) = pure $ maybeValue (user.id == 1) updateUserRightValue

deleteUser :: UserId -> Aff (Maybe User)
deleteUser userId = pure $ maybeValue (userId == 1) deleteUserRightValue

listUsers :: Aff (Array (User))
listUsers = pure $ listUsersValue

