module Server.Shell.Api.Payload where

import Payload.Spec (DELETE, GET, POST, Spec(Spec))
import Server.Shared.Types (IdParam, Pool(..))
import Server.Shell.Interface.Persistence (Handle(..))
import Server.User.Api.Payload as UserApi
import Server.User.Persistence.Mock as UserMock
import Server.User.Persistence.MySQL as UserMySQL
import Server.User.Types (NewUser, User)

spec ::
  Spec
    { getUser ::
        GET "/v1/user/<id>"
          { params :: IdParam
          , response :: User
          }
    , listUsers ::
        GET "/v1/users"
          { response :: Array User }
    , deleteUser ::
        DELETE "/v1/user/<id>"
          { params :: IdParam
          , response :: User
          }
    , createUser ::
        POST "/v1/user"
          { body :: NewUser
          , response :: User
          }
    , updateUser ::
        POST "/v1/user/<id>"
          { params :: IdParam
          , body :: User
          , response :: User
          }
    }
spec = Spec

handlers :: Handle -> _
handlers (Handle shellHandle) =
  { getUser: UserApi.getUser userHandle
  , listUsers: UserApi.listUsers userHandle
  , deleteUser: UserApi.deleteUser userHandle
  , createUser: UserApi.createUser userHandle
  , updateUser: UserApi.updateUser userHandle
  }
  where
  userHandle = case shellHandle.pool of
    MySQL pool -> UserMySQL.mkHandle pool
    None -> UserMock.mkHandle

