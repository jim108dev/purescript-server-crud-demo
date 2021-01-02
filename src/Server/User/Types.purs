module Server.User.Types where

import Prelude
import Data.Array.NonEmpty (singleton)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Eq (genericEq)
import Data.Generic.Rep.Show (genericShow)
import Data.String (length)
import Data.Validation.Semigroup (V, invalid)
import Foreign (renderForeignError)
import Foreign.Class (class Decode, class Encode)
import Foreign.Generic (defaultOptions, genericDecode, genericEncode)
import Payload.ResponseTypes (Json(..), Response(..))
import Payload.Server.DecodeBody (class DecodeBody)
import Payload.Server.Response (class EncodeResponse, encodeResponse)
import Shared.Util.Validation (ValidationErrors, intercalateErrors, toEitherString)
import Simple.JSON as SJ

newtype NewUser
  = NewUser
  { name :: String
  }

mkNewUser :: String -> NewUser
mkNewUser name = NewUser { name }

derive instance genericNewUser :: Generic NewUser _

instance showNewUser :: Show NewUser where
  show = genericShow

instance decodeNewUser :: Decode NewUser where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }

instance encodeNewUser :: Encode NewUser where
  encode = genericEncode $ defaultOptions { unwrapSingleConstructors = true }

derive newtype instance readForeignNewUser :: SJ.ReadForeign NewUser
derive newtype instance writeForeignNewUser :: SJ.WriteForeign NewUser

instance decodeNewBodyUser :: SJ.ReadForeign NewUser => DecodeBody NewUser where
  decodeBody str = case SJ.readJSON str of
    Left e -> Left $ intercalateErrors $ renderForeignError <$> e
    Right u -> toEitherString $ validateNewUser u

-- User
type UserId
  = Int

newtype User
  = User
  { id :: UserId
  , name :: String
  }

mkUser :: Int -> String -> User
mkUser id name = User { id, name }

derive instance genericUser :: Generic User _

instance showUser :: Show User where
  show = genericShow

instance eqUser :: Eq User where
  eq = genericEq

instance decodeUser :: Decode User where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }

instance encodeUser :: Encode User where
  encode = genericEncode $ defaultOptions { unwrapSingleConstructors = true }

derive newtype instance readForeignUser :: SJ.ReadForeign User
derive newtype instance writeForeignUser :: SJ.WriteForeign User

instance decodeBodyUser :: SJ.ReadForeign User => DecodeBody User where
  decodeBody str = case SJ.readJSON str of
    Left e -> Left $ intercalateErrors $ renderForeignError <$> e
    Right u -> toEitherString $ validateUser u

instance encodeResponseUser :: SJ.WriteForeign User => EncodeResponse User where
  encodeResponse (Response r) = encodeResponse (Response $ r { body = Json r.body })

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
  mkUser
    <$> (validateId "id" u.id)
    <*> (validateName "name" u.name)

validateNewUser :: NewUser -> V ValidationErrors NewUser
validateNewUser (NewUser u) =
  mkNewUser
    <$> (validateName "name" u.name)

