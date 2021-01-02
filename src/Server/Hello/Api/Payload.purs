module Server.Hello.Api.Payload where

import Payload.Spec (GET, Routes, Spec(Spec))
import Server.Shared.Types (IdParam, Pool(..))
import Server.Shell.Interface.Persistence (Handle(..))
import Server.User.Api.Payload as UserApi
import Server.User.Persistence.Mock as UserMock
import Server.User.Persistence.MySQL as UserMySQL
import Server.User.Types (User)

spec ::
  Spec
    { guards :: {}
    , routes ::
        { v1 ::
            Routes "/v1"
              { user ::
                  Routes "/user"
                    { byId ::
                        Routes "/<id>"
                          { params :: IdParam
                          , get ::
                              GET "/"
                                { response :: User
                                }
                          }
                    }
              }
        }
    }
spec = Spec

handlers :: _
handlers (Handle shellHandle) =
  { v1:
      { user:
          { byId:
              { get: UserApi.getUser userHandle
              }
          }
      }
  }
  where
  userHandle = case shellHandle.pool of
    MySQL pool -> UserMySQL.mkHandle pool
    None -> UserMock.mkHandle

guards :: {}
guards = {}

