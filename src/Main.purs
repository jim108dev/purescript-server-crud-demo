module Main where

import Effect (Effect)
import Node.HTTP (Server)
import SimpleService.Server (runServer)

main :: Effect Server
main = runServer

