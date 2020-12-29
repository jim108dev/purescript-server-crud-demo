module Test.Server.Api (testSuite) where

import Prelude

import Control.Monad.Free (Free)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Foreign.Generic (encodeJSON)
import Node.Express.App (App, delete, get, post, setProp, useExternal)
import Node.Express.Test.Mock (MockResponse, TestMockApp, assertData, sendError, sendRequest, setBody, setRouteParam, setupMockApp, testExpress)
import Node.Express.Types (Method(..))
import Server.Shell.Api.BodyParser (jsonBodyParser)
import Server.User.Api.Main (createUser, deleteUser, getUser, listUsers, updateUser)
import Server.User.Persistence.Mock (findUserRightValue, insertUserRightValue, listUsersValue)
import Server.User.Persistence.Mock as UserMock
import Server.User.Types (User)
import Test.Unit (TestF, suite)

manageRequests :: App
manageRequests = do
  setProp "json spaces" 4.0
  useExternal jsonBodyParser
  get "/v1/user/1" $ getUser h
  get "/v1/users" $ listUsers h
  delete "/v1/user/1" $ deleteUser h
  post "/v1/users" $ createUser h
  post "/v1/user/:id" $ updateUser h
  where
  h = UserMock.makeHandle

testValue :: String
testValue = "TestValue"

sendTestRequest ::
  Method ->
  String ->
  (MockResponse -> TestMockApp) ->
  TestMockApp
sendTestRequest method url testResponse = sendRequest method url (\x -> x) testResponse

sendTestError :: (MockResponse -> TestMockApp) -> TestMockApp
sendTestError testResponse = sendError GET "http://example.com/" testValue testResponse

showResponse :: User -> MockResponse -> TestMockApp
showResponse expected response = liftEffect $ log response.data

-- assertUser expected response = lift $ assertMatch "Response data" expected $ actualValue
testServer :: Free TestF Unit
testServer =
  testExpress "GET"
    $ do
        setupMockApp $ manageRequests
        sendTestRequest GET "http://example.com/v1/users" $ assertData $ encodeJSON listUsersValue
        sendRequest GET "http://example.com/v1/user/1" withRouteParam $ showResponse findUserRightValue
        sendRequest POST "http://example.com/v1/users" withBody $ showResponse insertUserRightValue
  where
  withRouteParam = setRouteParam "id" "1"

  withBody = setBody $ "name: \"user2\""

testSuite :: Free TestF Unit
testSuite =
  suite "Application" do
    testServer

