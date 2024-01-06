// Set this to the number of nodes you want to create.
local nodecount = 6;
local replicas = 1;

// This is a function that generates the configuration for a single redis node.
local RedisNode(num) = {
  image: 'docker.io/redis:latest',
  volumes: [
    std.format('redis-data-%d:/data', num),
    './redis:/redis',
  ],
  command: [
    'redis-server',
    '/redis/redis.conf',
    '--port',
    std.format('%d', 7000 + num),
  ],
  network_mode: 'host',
  healthcheck: {
    test: ['CMD', 'redis-cli', '-p', std.format('%d', 7000 + num), '-c', 'ping'],
    retries: '3',
    timeout: '2s',
    interval: '5s',
  },
  ports: [
    std.format('%d:7000', 7000 + num),
  ],
};

// This generates the "volumes" entries for our compose file
local volumes = {
  [std.format('redis-data-%d', x)]: {}
  for x in std.range(1, nodecount)
};

// This generates the "services" entries for our compose file. We generate multiple nodes
// by calling the RedisNode() function nodecount times, and then we add our
// redis-cluster-creator container.
local services = {
  [std.format('redis-node-%d', x)]: RedisNode(x)
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
