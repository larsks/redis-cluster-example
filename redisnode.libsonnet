// Generate the configuration for a single redis node.
function(num) {
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
}
