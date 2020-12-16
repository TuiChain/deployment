#!/bin/bash

set -e
. "functions.sh"

# ---------------------------------------------------------------------------- #

pp_info "required-tools" "Checking if you have all the required tools"

## docker
if not_installed "docker"; then
  pp_error "required-tools" "
  We are using docker for deploying locally the TuiChain Platform. Pls install it and run this script again.
  "

  exit 1
else
  pp_success "required-tools" "docker is installed"

  if ! docker info > /dev/null 2>&1; then
    pp_warn "required-tools" "docker does not seem to be running, run it first and retry"
    exit 1
  else
    pp_success "required-tools" "docker is up-and-running"
  fi

fi

## docker-compose
if not_installed "docker-compose"; then
  
  pp_error "required-tools" "We are using docker-compose for deploying locally the TuiChain Platform. Pls install it and run this script again."
  
  exit 1

else

  pp_success "required-tools" "docker-compose is installed"

fi

pp_success "required-tools" "All tools are installed"

# ---------------------------------------------------------------------------- #

pp_info "setup" "Setting up the environment"

## backend
cp ./backend-docker/Dockerfile ../backend/Dockerfile
pp_success "setup" "Backend Dockerfile copied to backend folder"

## frontend
# cp ./frontend-docker/Dockerfile ../frontend/Dockerfile
# pp_success "setup" "Frontend Dockerfile copied to frontend folder"


# ---------------------------------------------------------------------------- #

# pp_info "deployment" "Deploying components in docker"



