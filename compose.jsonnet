// Set this to the number of nodes you want to create.
local nodecount = 6;
local replicas = 1;

local redisnode = import 'redisnode.libsonnet';

// Generate redis node definitions
local nodes = {
  [std.format('redis-node-%d', x)]: redisnode(x)
  for x in std.range(1, nodecount)
};

// Generate one data volume per node
local volumes = {
  [std.format('redis-data-%d', node.id)]: {}
  for node in std.objectValues(nodes)
};

// Final services for compose file -- all the nodes plus the
// redis-cluster-creator container.
local services = nodes {
  'redis-cluster-creator': {
    image: 'docker.io/redis:latest',
    depends_on: {
      [std.format('redis-node-%d', node.id)]: {
        condition: 'service_healthy',
      }
      for node in std.objectValues(nodes)
    },
    network_mode: 'host',
    command:
      ['redis-cli', '--cluster', 'create'] +
      [std.format('localhost:%d', 7000 + node.id) for node in std.objectValues(nodes)] +
      ['--cluster-yes', '--cluster-replicas', std.format('%d', replicas)],
  },
};

{
  volumes: volumes,
  services: services,
}
