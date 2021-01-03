module Test.Main where

import Prelude
import Effect (Effect)
import Effect.Aff as Aff
import Test.Server.User.Api.PayloadSpec as ServerUserApi
import Test.Unit (TestSuite, suite)
import Test.Unit.Main (runTestWith)
import Test.Unit.Output.Fancy as Fancy

tests :: TestSuite
tests = do
  suite "Server" do
    ServerUserApi.tests

main :: Effect Unit
main =
  Aff.launchAff_
    $ do
        runTestWith Fancy.runTest tests

