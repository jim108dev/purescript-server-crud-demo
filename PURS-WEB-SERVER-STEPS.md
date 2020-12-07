# Steps for reproduction

## Workspace setup

1. Install necessary software as described at [Getting Started with PureScript](https://github.com/purescript/documentation/blob/master/guides/Getting-Started.md)

1. Installation:

    ```sh
    mkdir purs-web-server
    cd purs-web-server
    spago init
    spago build

    # Install additional packages
    spago install purescript-foreign-generic
    spago install purescript-generics-rep
    ```

1. Create `src/SimpleService/.purs`: Derive instances `showUser`, `decodeUser` and `encodeUser`.

1. Try in repl:

    ```purescript
    spago repl
    import SimpleService.
    user = User { id: 1, name: "Jim"}
    user

    import Foreign.Generic
    userJSON = encodeJSON user
    userJSON

    import Foreign
    import Control.Monad.Except.Trans
    import Data.Identity
    dUser = decodeJSON userJSON :: F User
    eUser = let (Identity eUser) = runExceptT $ dUser in eUser
    eUser
    ```

### PostgreSQL

Because 1. the `purescript-postgresql-client` was not in the latest packages list (see below) and even after fixing this, it did not work in `repl` and in the source code, MariaDB was used. (see #MariaDB)

1. Setup postgres [https://wiki.debian.org/PostgreSql](https://wiki.debian.org/PostgreSql):

    ```sh
    sudo apt update
    sudo apt install postgresql postgresql-client
    sudo -u postgres bash
    psql
    create database simple_service;
    \c simple_service
    create table users (id int primary key, name varchar(100) not null);
    \d users
    insert into users (id, name) values (1, 'a');
    select * from users;
    \q

    # Install dependencies
    npm init -y
    npm install pg --save
    spago install purescript-aff
    spago install purescript-postgresql-client
    # did not work
    #[error] The following packages do not exist in your package set:
    #[error]   - purescript-postgresql-client
    ```

1. `packages.dhall`: Add `purescript-postgresql-client` dependency. This package is not in the [current package list](https://github.com/purescript/package-sets/releases/download/psc-0.13.8-20201125/packages.dhall), it must be manually added. The code was taken from [https://github.com/melanchat/melanchat](https://github.com/melanchat/melanchat).

### MariaDB setup

See [(Ellingwood, 2019)](https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-debian-10) for details.

1. Install: Problem: The current debian version of MariaDB 10.4 has no `INSERT ... RETURNING` support. Sol.: Goto [https://downloads.mariadb.org](https://downloads.mariadb.org). Choose mirror.

   ```sh
   sudo apt-get install software-properties-common dirmngr
   sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
   sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror2.hs-esslingen.de/mariadb/repo/10.5/debian buster main'
   
   sudo apt update
   sudo apt install mariadb-server
   ```

1. Configure:

   ```sh
   sudo mysql_secure_installation
   #Options: none,N, defaults
   ```

1. Add admin user

   ```sh
   sudo mariadb
   GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;
   FLUSH PRIVILEGES;
   exit
   ```

1. Test admin user

   ```sh
   mysqladmin -u admin -p version
   ```

1. Start, stop, status:

   ```sh
   sudo systemctl start mariadb
   sudo systemctl status mariadb
   sudo systemctl stop mariadb

   ```

1. Setup mariadb connection with VS Code extension *SQLTools MySQL/MariaDB Driver*.
1. Create `INIT_DB.sql`: Add `CREATE DATABASE simple_service`. Add `CREATE TABLE users`.

1. Install in project:

    ```sh
    npm install mysql
    spago install purescript-mysql
    ```

### Express setup

1. Install Express:

    ```sh
    npm install express --save
    npm install decimal.js --save
    spago install purescript-express
    ```

### Select and delete requests

1. Create `.purs`: Add `readForeignUser` and `writeForeignUser`
1. Create `Persistence.purs`: Add `insertUser`,`findUser`,`updateUser`, `deleteUser`, `listUsers`. Create test sql scripts inside directory`sql`.
1. Create `Server.purs`: Add `createPool'`, `appSetup` and `runServer`.
1. `Main.purs`: Add `main=runServer`.
1. Test:

    ```sh
    # first terminal
    spago run

    # second terminal
    sudo apt install httpie
    http GET http://localhost:4000/v1/user/1 #returns 200
    http GET http://localhost:4000/v1/users #returns 404
    http DELETE http://localhost:4000/v1/user/1 #returns 200
    http GET http://localhost:4000/v1/user/1 #now returns 200
    ```

### Create user request

1. Create `Middleware/BodyParser.js`: Export `jsonBodyParser`. Limit payload to 1 mb.

1. Install

    ```sh
    npm install --save body-parser
    ```

1. Create `Middleware/BodyParser.purs`: Add `foreign import jsonBodyParser`.
1. `Types.purs`: Add `NewUser`.
1. `Handler.purs`: Add `createUser`.
1. Test:

    ```sh
    # first terminal
    spago run

    # second terminal
    http POST http://localhost:4000/v1/users name=John #returns 200
    http GET http://localhost:4000/v1/user/16 #now returns 200
    http DELETE http://localhost:4000/v1/user/16 #returns 204
    http GET http://localhost:4000/v1/user/18 #now returns 404
    ```

### Update user request

1. `Handler.purs`: Add `updateUser`.
1. `Server.purs`: Add `put` linking to `updateUser`.
1. Test:

    ```sh
    http GET http://localhost:4000/v1/user/2 #now returns 200
    http POST http://localhost:4000/v1/user/2 id:=2 name=Hans 
    ```

### List all users

1. `Handler.purs`: Add `listUsers`.
