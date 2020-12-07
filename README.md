# PureScript Web Server

This is a learning project in order to set up a Node.js server with PureScript. The contents is copy and paste from [(Sarkar, 2017)](https://abhinavsarkar.net/posts/ps-simple-rest-service/). Changes were necessary because some of the software packages were already outdated.

## Install

1. Install software

```sh
git clone https://github.com/jim108dev/purescript-web-server.git
cd purescript-web-server
yarn
```

1. Install *MariaDB*. Init database: Run `sql/INIT_DB.sql`.

## Usage

```sh
#1. terminal
spago run 
# 2. terminal
http POST http://localhost:4000/v1/users name=Joe # Create user Jim
http GET http://localhost:4000/v1/users # Show users
http DELETE http://localhost:4000/v1/users/1 # Delete user
http GET http://localhost:4000/v1/users # Show users
```

## Development

`PURESCRIPT-WEB-SERVER-STEPS.md` contains *steps for reproduction*.
