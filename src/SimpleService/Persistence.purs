module SimpleService.Persistence
  ( findUser
  , insertUser
  , updateUser
  , deleteUser
  , listUsers
  ) where

import Prelude

import Data.Array (head)
import Data.Maybe (Maybe)
import Effect.Aff (Aff)
import MySQL.Connection as DB
import MySQL.Pool (Pool, withPool)
import MySQL.QueryValue (toQueryValue)
import SimpleService.Types (NewUser(..), User(..), UserId)

findUser :: Pool -> UserId -> Aff (Maybe User)
findUser pool userId = do
  userArray <-
    withPool
      ( \conn ->
          DB.query "SELECT * FROM users WHERE id = ?"
            [ toQueryValue userId ]
            conn
      )
      pool
  pure $ head $ userArray

insertUser :: Pool -> NewUser -> Aff (Maybe User)
insertUser pool (NewUser user) = do
  arr <-
    withPool
      ( \conn ->
          DB.query "INSERT INTO users (name) VALUES (?) RETURNING *"
            [ toQueryValue user.name ]
            conn
      )
      pool
  pure $ head $ arr

updateUser :: Pool -> User -> Aff Unit
updateUser pool (User user) =
  withPool
    ( \conn ->
        DB.execute "UPDATE users SET name = ? WHERE id = ?"
          [ toQueryValue user.name, toQueryValue user.id ]
          conn
    )
    pool

deleteUser :: Pool -> UserId -> Aff (Maybe User)
deleteUser pool userId = do
  arr <-
    withPool
      ( \conn ->
          DB.query "DELETE FROM users WHERE id = ? RETURNING *"
            [ toQueryValue userId ]
            conn
      )
      pool
  pure $ head $ arr

listUsers :: Pool -> Aff (Array (User))
listUsers pool = do
  withPool
    ( \conn ->
        DB.query_ "SELECT * FROM users"
          conn
    )
    pool

