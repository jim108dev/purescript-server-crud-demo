module Test.Server.User.Api.PayloadSpec where

import Prelude
import Data.Maybe (Maybe(..))
import Foreign.Generic (encodeJSON)
import Server.Shared.Util.Payload (request, respMatches, withRoutes)
import Server.Shell.Api.Payload (handlers, spec)
import Server.Shell.Persistence.Mock as Mock
import Server.User.Persistence.Mock (deleteUserRightValue, findUserRightValue, insertUserRightValue, listUsersValue, updateUserRightValue)
import Test.Unit (TestSuite, suite, test)
import Test.Unit.Assert as Assert

tests :: TestSuite
tests = do
  let
    handle = Mock.mkHandle

    withApi = withRoutes spec (handlers handle)

    { get, post, delete } = request "http://localhost:3000"
  suite "User GET requests" do
    test "GET /v1/user/1 succeeds"
      $ withApi do
          res <- get "/v1/user/1"
          respMatches
            { status: 200
            , body: encodeJSON findUserRightValue
            }
            res
    test "GET /v1/user/x fails with 404"
      $ withApi do
          res <- get "/v1/user/x"
          Assert.equal 404 res.status
    test "GET /v1/users succeeds"
      $ withApi do
          res <- get "/v1/users"
          respMatches
            { status: 200
            , body: encodeJSON listUsersValue
            }
            res
  suite "User POST requests for creation" do
    test "POST /v1/user returns 200 (ok) and created user"
      $ withApi do
          res <- post "/v1/user" $ "{ \"name\": \"userInserted\" }"
          respMatches
            { status: 200
            , body: encodeJSON insertUserRightValue
            }
            res
    test "POST /v1/user fails with 400 (bad request) because of illegal name"
      $ withApi do
          let
            illegalName = "123456789012345678901234567890123456789012345678901"
          res <- post "/v1/user" $ "{\"name\":\"" <> illegalName <> "\"}"
          Assert.equal 400 res.status
    test "POST /v1/user fails with 404 (not found)"
      $ withApi do
          res <- post "/v1/user" $ "{ \"name\": \"notFound\" }"
          Assert.equal 404 res.status
  suite "User POST requests for update" do
    test "POST /v1/user/1 returns 200 (ok) and updated user"
      $ withApi do
          res <- post "/v1/user/1" $ encodeJSON updateUserRightValue
          respMatches
            { status: 200
            , body: encodeJSON updateUserRightValue
            }
            res
    test "POST /v1/user/1 fails with 400 (bad request) because of illegal name"
      $ withApi do
          let
            illegalName = "123456789012345678901234567890123456789012345678901"
          res <- post "/v1/user/1" $ "{\"id\":1, \"name\":\"" <> illegalName <> "\"}"
          Assert.equal 400 res.status
    test "POST /v1/user/2 fails with 404 (not found)"
      $ withApi do
          res <- post "/v1/user" $ "{ \"id\":2, \"name\": \"notUser2\" }"
          Assert.equal 404 res.status
  suite "User DELETE requests for delete" do
    test "DELETE /v1/user/1 returns 200 (ok) and deleted user"
      $ withApi do
          res <- delete "/v1/user/1" Nothing
          respMatches { status: 200, body: encodeJSON deleteUserRightValue } res
    test "DELETE /v1/user/2 fails with 404 (not found)"
      $ withApi do
          res <- delete "/v1/user/2" Nothing
          Assert.equal 404 res.status

