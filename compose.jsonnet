// Set this to the number of nodes you want to create.
local nodecount = 6;
local replicas = 1;

local redisnode = import 'redisnode.libsonnet';

// This generates the "volumes" entries for our compose file
local volumes = {
  [std.format('redis-data-%d', x)]: {}
  for x in std.range(1, nodecount)
};

// This generates the "services" entries for our compose file. We generate multiple nodes
// by calling the redisnode() function nodecount times, and then we add our
// redis-cluster-creator container.
local services = {
  [std.format('redis-node-%d', x)]: redisnode(x)
  for x in std.range(1, nodecount)
} + {
  'redis-cluster-creator': {
    image: 'docker.io/redis:latest',
    depends_on: {
      [std.format('redis-node-%d', x)]: {
        condition: 'service_healthy',
      }
      for x in std.range(1, nodecount)
    },
    network_mode: 'host',
    command:
      ['redis-cli', '--cluster', 'create'] +
      [std.format('localhost:%d', 7000 + x) for x in std.range(1, nodecount)] +
      ['--cluster-yes', '--cluster-replicas', std.format('%d', replicas)],
  },
};

{
  volumes: volumes,
  services: services,
}
