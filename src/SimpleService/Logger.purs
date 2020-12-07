module Logger (info) where

import Prelude
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console (logShow)

info :: forall a m. MonadEffect m => Show a => a -> m Unit
info x = liftEffect $ logShow $ "INFO: " <> show x

