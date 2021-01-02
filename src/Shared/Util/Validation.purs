module Shared.Util.Validation where

import Prelude

import Control.Monad.Except.Trans (ExceptT, except)
import Data.Array.NonEmpty (NonEmptyArray)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Foldable (class Foldable, intercalate)
import Data.Maybe (Maybe(..))
import Data.Validation.Semigroup (V(..), toEither)
import Shared.Types (Error, markError)

type ValidationErrors
  = NonEmptyArray String

exceptMaybe :: forall m a. Applicative m => Int -> String -> Maybe a -> ExceptT Error m a
exceptMaybe code message a =
  except
    $ case a of
        Just x -> Right x
        Nothing -> Left $ markError code message

intercalateErrors :: forall a. Foldable a => a String -> String
intercalateErrors = intercalate ". "

toEitherString :: forall a. V ValidationErrors a -> Either String a
toEitherString = toEither >>> lmap intercalateErrors

