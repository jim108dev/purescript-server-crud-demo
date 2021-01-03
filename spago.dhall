{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "assert"
  , "console"
  , "dotenv"
  , "effect"
  , "express"
  , "foreign"
  , "foreign-generic"
  , "formatters"
  , "logging"
  , "mysql"
  , "node-process"
  , "now"
  , "payload"
  , "psci-support"
  , "validation"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
