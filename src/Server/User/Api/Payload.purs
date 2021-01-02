module Server.User.Api.Payload where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Payload.ResponseTypes (Failure(..), ResponseBody(..))
import Payload.Server.Response (notFound)
import Server.Shared.Types (IdParam, IdParamContainer)
import Server.User.Interface.Persistence (Handle(..))
import Server.User.Types (NewUser, User)

mkResponse :: forall a. Maybe a -> Either Failure a
mkResponse Nothing = Left $ Error $ notFound $ EmptyBody
mkResponse (Just v) = Right v

getUser :: Handle -> IdParamContainer -> Aff (Either Failure User)
getUser (Handle h) { params: { id } } = h.findUser id <#> mkResponse

listUsers :: Handle -> {} -> Aff (Array User)
listUsers (Handle h) _ = h.listUsers

deleteUser :: Handle -> IdParamContainer -> Aff (Either Failure User)
deleteUser (Handle h) { params: { id } } = h.deleteUser id <#> mkResponse

createUser :: Handle -> { body :: NewUser } -> Aff (Either Failure User)
createUser (Handle h) { body } = h.insertUser body <#> mkResponse

updateUser :: Handle -> { params :: IdParam, body :: User } -> Aff (Either Failure User)
updateUser (Handle h) { params: { id }, body } = h.updateUser body <#> mkResponse

