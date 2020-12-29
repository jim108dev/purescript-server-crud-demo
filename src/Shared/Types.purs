module Shared.Types where

import Data.Array.NonEmpty (NonEmptyArray, singleton)

data Error
  = Error Int (NonEmptyArray String)

markError :: Int -> String -> Error
markError code message = Error code (singleton message)

