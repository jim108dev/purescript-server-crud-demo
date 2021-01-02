module Server.User.Api.Express where

import Prelude
import Control.Monad.Except (runExcept)
import Control.Monad.Except.Trans (ExceptT, except, lift, runExceptT)
import Data.Either (Either(..))
import Data.Int (fromString)
import Data.Validation.Semigroup (toEither)
import Effect.Aff.Class (liftAff)
import Foreign (renderForeignError)
import Foreign.Generic.Class (encode)
import Node.Express.App (App, get, delete, post)
import Node.Express.Handler (Handler, HandlerM)
import Node.Express.Request (getBody, getRouteParam)
import Server.Shared.Api.Express (respond, sendResult)
import Server.User.Interface.Persistence (Handle(..))
import Server.User.Types (NewUser(..), User(..), validateNewUser, validateUser)
import Shared.Types (Error(..))
import Shared.Util.String (format1)
import Shared.Util.Validation (exceptMaybe)

manageRequests :: Handle -> App
manageRequests h = do
  get "/v1/user/:id" $ getUser h
  get "/v1/users" $ listUsers h
  delete "/v1/user/:id" $ deleteUser h
  post "/v1/users" $ createUser h
  post "/v1/user/:id" $ updateUser h

getId :: ExceptT Error HandlerM String
getId = lift (getRouteParam "id") >>= exceptMaybe 422 "User id is missing"

idToInt :: String -> ExceptT Error HandlerM Int
idToInt sUserId =
  lift (pure (fromString sUserId))
    >>= exceptMaybe 422 "User id could not be converted to integer"

findUser :: Handle -> Int -> ExceptT Error HandlerM User
findUser (Handle h) id =
  liftAff (h.findUser id)
    >>= exceptMaybe 422 (format1 "User id {1} is not persisted" id)

getUser :: Handle -> HandlerM Unit
getUser h = runExceptT (getId >>= idToInt >>= findUser h) >>= sendResult

listUsers :: Handle -> Handler
listUsers (Handle h) = liftAff h.listUsers >>= encode >>> respond 200

deleteUser' :: Handle -> Int -> ExceptT Error HandlerM User
deleteUser' (Handle h) id =
  liftAff (h.deleteUser id)
    >>= exceptMaybe 404 (format1 "User id {1} not found in storage" id)

deleteUser :: Handle -> Handler
deleteUser h = runExceptT (getId >>= idToInt >>= deleteUser' h) >>= sendResult

validateUser' :: forall m. Applicative m => User -> ExceptT Error m User
validateUser' user =
  except
    $ case toEither (validateUser user) of
        Left e -> Left $ Error 422 e
        Right a -> Right a

validateNewUser' :: forall m. Applicative m => NewUser -> ExceptT Error m NewUser
validateNewUser' user =
  except
    $ case toEither (validateNewUser user) of
        Left e -> Left $ Error 422 e
        Right a -> Right a

updateUser' :: Handle -> User -> ExceptT Error HandlerM User
updateUser' (Handle h) uRecord@(User user) =
  liftAff (h.updateUser uRecord)
    >>= exceptMaybe 404 (format1 "User id {1} not found in storage" user.id)

updateUser :: Handle -> Handler
updateUser h =
  runExcept <$> getBody
    >>= case _ of
        Left errs -> respond 422 { errors: renderForeignError <$> errs }
        Right user -> runExceptT (validateUser' user >>= updateUser' h) >>= sendResult

insertUser :: Handle -> NewUser -> ExceptT Error HandlerM User
insertUser (Handle h) uRecord@(NewUser user) =
  liftAff (h.insertUser uRecord)
    >>= exceptMaybe 404 (format1 "User name {1} could not be inserted" user.name)

createUser :: Handle -> Handler
createUser h =
  runExcept <$> getBody
    >>= case _ of
        Left errs -> respond 422 { errors: renderForeignError <$> errs }
        Right user -> runExceptT (validateNewUser' user >>= insertUser h) >>= sendResult

