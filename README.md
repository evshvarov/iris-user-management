# iris-user-management
A simple module to maintain users logged via OAuth providers e.g. Google, Meta, etc

## Installation 

via IPM: 
zpm "install shvarov-user-management"

## Setup Dev environment for contribution/testing
Clone/git pull the repo into any local directory

```
$ git clone git@github.com:evshvarov/iris-user-management.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How it works

the module installs /auth end-point that provides a {backend API}(https://github.com/evshvarov/iris-user-management/blob/master/src/shvarov/oauth/google/spec.cls) for code->token exchange (now for google only) and to sign-in the user (will be stored in um.users class), also to prove JWT token in Google that is being used for your API.

Expects GOOGLE_CLIENT_ID and GOOGLE_SECRET_KEY passed as env variables



