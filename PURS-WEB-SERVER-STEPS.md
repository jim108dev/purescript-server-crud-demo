# Steps for Reproduction

My setup was Debian 10. Node v15.2.1.

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

### Express setup

1. Install Express:

    ```sh
    npm install express --save
    npm install decimal.js --save
    spago install purescript-express
    ```

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
1. Create `INIT_DB.sql`: Add `CREATE DATABASE a_database`. Add `CREATE TABLE users`.

1. Install in project:

    ```sh
    npm install mysql
    spago install purescript-mysql
    ```

## Source code file and folder structure

1. The general source code file and folder structure is `<src-folder>/<app>/<domain>/<layer>/<file>`.
    1. `<src-folder>`:
        1. `sql`: Contains sql scripts for development and database setup.
        1. `src`: PureScript and JavaScript development source files.
        1. `test`: Test cases.
    1. `<app>`:
        1. `Client`: Code which is only used in the client application. (Not implemented yet)
        1. `Server`: Code which is only used in the server application.
        1. `Shared`: Code which can be used by all apps.
    1. `<domain>`:
        1. `Shell`: For the entry point of the application and to direct to other domains.
        1. `User`: User domain code.
        1. `Shared`: Code which can be used by all domains.
    1. `<layer>`:
        1. `Api`: Entry, exit points of requests and validation logic.
        1. `Application`: Business application layer. Layers which rely on effects can only be used with interfaces. If there is no business logic, the layer is omitted.
        1. `Interface`: Interfaces for persistence or application functions.
        1. `Persistence`: Persistence/storage/database layer.
        1. `Util`: Holds util functions which can be used in every layer.
    1. `<file>`: If there can be multiple implementations of the same layer, a distinct name is used. `Main.purs` refers to the general implementation/entrance point of a folder. `Types.purs` holds all data types, constructor functions, class and instance declarations.
1. The handle pattern was used for dependency injection following the description of [(Van der Jeugt, 2018)]([https://jaspervdj.be/posts/2018-03-08-handle-pattern.html]).
1. The source code is written for qualified import, which is also described by [(Van der Jeugt, 2018)]([https://jaspervdj.be/posts/2018-03-08-handle-pattern.html]).

## Testing

1. Quick one time only test:

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

1. Unit tests: `purescript-express` provides a package called `Node.Express.Test.Mock`. Sample test cases can be found at [https://github.com/purescript-express/purescript-express/tree/master/test/Test](purescript-express github). Route param replacement and the body parser did not work with the mock functions. ([https://discourse.purescript.org/t/purescript-express-test/1973]((Discourse)). My attempt is in the `test` folder.
