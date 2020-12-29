module Shared.User.Util.Validation where

import Prelude
import Data.Array.NonEmpty (singleton)
import Data.String (length)
import Data.Validation.Semigroup (V, invalid)
import Server.User.Types (NewUser(..), User(..), makeNewUser, makeUser)
import Shared.Util.Validation (ValidationErrors)

validateId :: String -> Int -> V ValidationErrors Int
validateId field id
  | id >= 0 = pure id

validateId field _ = invalid (singleton ("Field '" <> field <> "' must be a positive number"))

validateName :: String -> String -> V ValidationErrors String
validateName field name =
  let
    len = length name
  in
    case unit of
      _ | len > 0 && len <= 50 -> pure name
      _ | otherwise -> invalid (singleton ("Field '" <> field <> "' must be between 1 and 50 characters"))

validateUser :: User -> V ValidationErrors User
validateUser (User u) =
  makeUser
    <$> (validateId "id" u.id)
    <*> (validateName "name" u.name)

validateNewUser :: NewUser -> V ValidationErrors NewUser
validateNewUser (NewUser u) =
  makeNewUser
    <$> (validateName "name" u.name)

