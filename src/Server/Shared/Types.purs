module Server.Shared.Types where

import MySQL.Pool as MySQL

data Pool
  = MySQL MySQL.Pool
  | None

type Status
  = Int

