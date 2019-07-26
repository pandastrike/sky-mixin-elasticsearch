# Panda Sky Mixin: Elasticsearch
# This mixin allocates the requested Elasticsearch cluster into your CloudFormation stack.
import {cat, isObject, merge} from "panda-parchment"

preprocess = (SDK, global, meta, local) ->

  # Start by extracting out the Elasticsearch Mixin configuration:
  {vpc} = meta
  {cluster, tags={}} = local

  # This mixin only works with a VPC
  unless vpc
    throw new Error "The Elasticsearch mixin can only be used in environments featuring a VPC."

  unless cluster?
    throw new Error "Please specify a cluster configuration for the Panda Sky Elasticsearch mixin. A default configuration is available if you specify cluster as an empty object, {}"

  cluster.domain ?= global.environment.stack.name

  # By default, only use one Subnet from the template's parameter list.
  cluster.subnets = ['!Select [ 0, !Split [ ",", !Ref Subnets ] ]']

  # Apply default node configuration, if undefined.
  cluster.nodes ?=
    count: 1
    type: "t2.small.elasticsearch"

  # High availability configuration requires the use of the other subnet.
  cluster.nodes.highAvailability ?= false
  if cluster.nodes.highAvailability
    cluster.subnets.push '!Select [ 1, !Split [ ",", !Ref Subnets ] ]'

  # Convert the optional UTC hour for the snapshot into an object that avoids
  # "0 as falsey" parsing from handlebars.
  if cluster.snapshot?
    cluster.snapshot = hour: cluster.snapshot


  {
    cluster, tags
    accountID: global.accountID
  }

export default preprocess
