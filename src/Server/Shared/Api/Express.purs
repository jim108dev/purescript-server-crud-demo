module Server.Shared.Api.Express where

import Prelude
import Data.Either (Either(..))
import Node.Express.Handler (Handler)
import Node.Express.Response (sendJson, setStatus)
import Server.Shared.Types (Status)
import Shared.Types (Error(..))

respond :: forall a. Status -> a -> Handler
respond status body = do
  setStatus status
  sendJson body

sendResult :: forall a. Either Error a -> Handler
sendResult result = case result of
  Left (Error c e) -> respond c { error: e }
  Right a -> respond 200 a

