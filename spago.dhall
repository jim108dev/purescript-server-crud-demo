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
  , "effect"
  , "express"
  , "foreign"
  , "foreign-generic"
  , "formatters"
  , "logging"
  , "mysql"
  , "node-process"
  , "now"
  , "psci-support"
  , "validation"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
