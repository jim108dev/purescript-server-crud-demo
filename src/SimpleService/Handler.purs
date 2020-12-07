module SimpleService.Handler where

import Prelude

import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Foldable (intercalate)
import Data.Int (fromString)
import Data.Maybe (Maybe(..))
import Effect.Aff.Class (liftAff)
import Foreign (renderForeignError)
import Foreign.Class (encode)
import MySQL.Pool (Pool)
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody, getRouteParam)
import Node.Express.Response (end, sendJson, setStatus)
import SimpleService.Persistence as P
import SimpleService.Types (NewUser(..), User(..))

respond :: forall a. Int -> a -> Handler
respond status body = do
  setStatus status
  sendJson body

respondNoContent :: Int -> Handler
respondNoContent status = do
  setStatus status
  end

getUser :: Pool -> Handler
getUser pool =
  getRouteParam "id"
    >>= case _ of
        Nothing -> respond 422 { error: "User ID is required" }
        Just sUserId -> case fromString sUserId of
          Nothing -> respond 422 { error: "User ID must be an integer: " <> sUserId }
          Just userId ->
            liftAff (P.findUser pool userId)
              >>= case _ of
                  Nothing -> respond 404 { error: "User not found with id: " <> sUserId }
                  Just user -> respond 200 (encode user)

deleteUser :: Pool -> Handler
deleteUser pool =
  getRouteParam "id"
    >>= case _ of
        Nothing -> respond 422 { error: "User ID is required" }
        Just sUserId -> case fromString sUserId of
          Nothing -> respond 422 { error: "User ID must be an integer: " <> sUserId }
          Just userId -> do
            liftAff (P.deleteUser pool userId)
              >>= case _ of
                  Nothing -> respond 404 { error: "User not found with id: " <> sUserId }
                  Just _ -> respondNoContent 204

createUser :: Pool -> Handler
createUser pool =
  runExcept <$> getBody
    >>= case _ of
        Left errs -> respond 422 { error: intercalate ", " $ map renderForeignError errs }
        Right payload@(NewUser newUser) ->
          if newUser.name == "" then
            respond 422 { error: "User name must not be empty" }
          else
            liftAff (P.insertUser pool payload)
              >>= case _ of
                  Nothing -> respond 404 { error: "User " <> newUser.name <> " creation failed" }
                  Just user -> respond 200 (encode user)

updateUser :: Pool -> Handler
updateUser pool =
  getRouteParam "id"
    >>= case _ of
        Nothing -> respond 422 { error: "User ID is required" }
        Just sUserId -> case fromString sUserId of
          Nothing -> respond 422 { error: "User ID must be positive: " <> sUserId }
          Just userId ->
            runExcept <$> getBody
              >>= case _ of
                  Left errs -> respond 422 { error: intercalate ", " $ map renderForeignError errs }
                  Right payload@(User user) ->
                    if user.name == "" then
                      respond 422 { error: "User name must not be empty" }
                    else do
                      liftAff (P.updateUser pool payload)
                      respond 200 (encode user)

listUsers :: Pool -> Handler
listUsers pool = liftAff (P.listUsers pool) >>= encode >>> respond 200

