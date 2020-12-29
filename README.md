# PureScript Web Server

This is a learning project in order to set up a Node.js server with PureScript. The contents is based on [(Sarkar, 2017)](https://abhinavsarkar.net/posts/ps-simple-rest-service/).

It is a REST API which can make CRUD requests to a MariaDB database.

## Install

1. Install repository 's  software

```sh
git clone https://github.com/jim108dev/purescript-web-server.git
cd purescript-web-server
npm install
```

1. Install MariaDB. Init database with `sql/INIT_DB.sql`.

1. Install HTTPie or other tools to make http calls.

## Usage

```sh
#1. terminal
spago run 
# 2. terminal
http POST http://localhost:4000/v1/users name=Joe # Create user Jim
http GET http://localhost:4000/v1/users # Show users
http DELETE http://localhost:4000/v1/user/20 # Delete user
http GET http://localhost:4000/v1/users # Show users
```

## Development

`PURS-WEB-SERVER-STEPS.md` contains *Steps for Reproduction*.
