# Panda Sky Mixin: Elasticsearch
# This mixin allocates the requested Elasticsearch cluster into your CloudFormation stack.
import {cat, isObject, merge} from "fairmont"

process = (SDK, config) ->

  # Start by extracting out the KMS Mixin configuration:
  {env, tags=[]} = config
  c = config.aws.environments[env].mixins.elasticsearch
  c = if isObject c then c else {}
  c.tags = cat (c.tags || []), tags

  # This mixin only works with a VPC
  if !config.aws.vpc
    throw new Error "The Elasticsearch mixin can only be used in environments featuring a VPC."

  # By default, only use one Subnet from the template's parameter list.
  subnets = ['"Fn::Select": [ 0, "Fn::Split": [ ",", {Ref: Subnets} ]]']
  if c.cluster
    {diskSize, master, nodes} = c.cluster
    if nodes?.highAvailability
      subnets.push '"Fn::Select": [1, "Fn::Split": [ ",", {Ref: Subnets} ]]'

  {
    diskSize, master, nodes, subnets
    tags: c.tags,
    accountID: config.accountID,
    domain: config.environmentVariables.fullName
  }

export default process
