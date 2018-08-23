"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _fairmont = require("fairmont");

// Panda Sky Mixin: Elasticsearch
// This mixin allocates the requested Elasticsearch cluster into your CloudFormation stack.
var process;

process = function (SDK, config) {
  var c, diskSize, env, master, nodes, subnets, tags;
  // Start by extracting out the KMS Mixin configuration:
  ({ env, tags = [] } = config);
  c = config.aws.environments[env].mixins.elasticsearch;
  c = (0, _fairmont.isObject)(c) ? c : {};
  c.tags = (0, _fairmont.cat)(c.tags || [], tags);
  if (!config.aws.vpc) {
    throw new Error("The Elasticsearch mixin can only be used in environments featuring a VPC.");
  }
  // By default, only use one Subnet from the template's parameter list.
  subnets = ['"Fn::Select": [ 0, "Fn::Split": [ ",", {Ref: Subnets} ]]'];
  if (c.cluster) {
    ({ diskSize, master, nodes } = c.cluster);
    if (nodes != null ? nodes.highAvailability : void 0) {
      subnets.push('"Fn::Select": [1, "Fn::Split": [ ",", {Ref: Subnets} ]]');
    }
  }
  return {
    diskSize,
    master,
    nodes,
    subnets,
    tags: c.tags,
    accountID: config.accountID,
    domain: config.environmentVariables.fullName
  };
};

exports.default = process;