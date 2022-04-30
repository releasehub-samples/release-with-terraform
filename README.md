# Extending Release Environments with Terraform

## Amazon ECS Example

This branch provides an example of using Release to create an ephemeral Amazon ECS container service with bring-your own Terraform.  creating an ephemeral ECS how you can use Release to create an ephemeral Amazon ECS container environment using your own custom Terraform.

## Prerequisites

The `main` branch contains an overview of how this project works and required pre-requisites that must be completed before deploying this branch to a Release environment. 

## Deployment

Refer to the `main` branch for deployment instructions.

## Terraform Lock File Management

The `./terraform.lock.hcl` file can either be committed to your repo to maintain consistent module versions or it can be ignored to allow `terraform init` to pull the latest module versions with each run. 

There are trade-offs with either approach, though this author personally prefers consistency and chooses to commit this file to source control.