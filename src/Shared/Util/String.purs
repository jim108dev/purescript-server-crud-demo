module Shared.Util.String where

import Prelude
import Data.String (Pattern(..), Replacement(..), replaceAll)

format1 :: forall a. Show a => String -> a -> String
format1 str x = replaceAll (Pattern ("{1}")) (Replacement (show x)) str

