module Shared.Util.Logger where

import Prelude

import Control.Logger as L
import Data.DateTime.Instant (toDateTime)
import Data.Either (fromRight)
import Data.Formatter.DateTime (Formatter, format, parseFormatString)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.String (toUpper)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Console as C
import Effect.Now (now)
import Partial.Unsafe (unsafePartial)

data Level
  = Debug
  | Info
  | Warn
  | Error

derive instance eqLevel :: Eq Level
derive instance ordLevel :: Ord Level
derive instance genericLevel :: Generic Level _

instance showLevel :: Show Level where
  show = toUpper <<< genericShow

type Entry
  = { level :: Level
    , message :: String
    }

dtFormatter :: Formatter
dtFormatter = unsafePartial $ fromRight $ parseFormatString "YYYY-MM-DD HH:mm:ss.SSS"

logger ::
  forall m.
  MonadEffect m =>
  L.Logger m Entry
logger =
  L.Logger
    $ \{ level, message } ->
        liftEffect do
          time <- toDateTime <$> now
          C.log $ "[" <> format dtFormatter time <> "] " <> show level <> " " <> message

log ::
  forall m.
  MonadEffect m =>
  Entry -> m Unit
log entry@{ level } = L.log (L.cfilter (\e -> e.level == level) logger) entry

debug ::
  forall m.
  MonadEffect m => String -> m Unit
debug message = log { level: Debug, message }

info ::
  forall m.
  MonadEffect m => String -> m Unit
info message = log { level: Info, message }

warn ::
  forall m.
  MonadEffect m => String -> m Unit
warn message = log { level: Warn, message }

error ::
  forall m.
  MonadEffect m => String -> m Unit
error message = log { level: Error, message }

