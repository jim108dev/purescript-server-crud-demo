module Server.Shared.Types where

import Data.Either (Either)
import MySQL.Pool as MySQL
import Payload.ResponseTypes (Failure)
import Server.User.Types (User)

data Pool
  = MySQL MySQL.Pool
  | None

type Status
  = Int

-- Payload Api
type IdParam
  = { id :: Int }

type IdParamContainer
  = { params :: IdParam }

type UserResponse
  = Either Failure User

type UsersResponse
  = { users :: Array User }

