cd#!/bin/bash

# Set the path to the directory containing the Go file
path="/home/ln64/Source/voxctl-go/cmd"

# Set the name of the Go file to be executed
file="main.go"

# Change to the directory containing the Go file
cd "$path"

# Load the environment variables
export $(grep -v '^#' /home/ln64/Desktop/voxctl-go/.env | xargs)

# Execute the Go file
go run "$file" -play "something newer"