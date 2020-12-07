module SimpleService.Types where

import Prelude
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Foreign.Class (class Decode, class Encode)
import Foreign.Generic (defaultOptions, genericDecode, genericEncode)
import Simple.JSON as Json

newtype NewUser
  = NewUser
  { name :: String
  }

derive instance genericNewUser :: Generic NewUser _

instance showNewUser :: Show NewUser where
  show = genericShow

instance decodeNewUser :: Decode NewUser where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }

instance encodeNewUser :: Encode NewUser where
  encode = genericEncode $ defaultOptions { unwrapSingleConstructors = true }

-- User
type UserId
  = Int

newtype User
  = User
  { id :: UserId
  , name :: String
  }

derive instance genericUser :: Generic User _

instance showUser :: Show User where
  show = genericShow

instance decodeUser :: Decode User where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }

instance encodeUser :: Encode User where
  encode = genericEncode $ defaultOptions { unwrapSingleConstructors = true }

derive newtype instance readForeignUser :: Json.ReadForeign User

derive newtype instance writeForeignUser :: Json.WriteForeign User

