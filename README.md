Start a Redis cluster using docker compose.

`compose.yaml` is generated from `compose.jsonnet`, since otherwise there's a lot of boilerplate configuration for each node.

To bring up this environment:

```
docker compose up
```

To clean everything up:

```
docker compose down -v
```

The `-v` flag instructs `docker compose` to remove volumes as well as containers.

If you make changes to `compose.jsonnet`, you will need to run `make` to rebuild `compose.yaml`. This requires [jsonnet] and [yq] (technically, `yq` isn't necessary; you can just run `jsonnet -o compose.yaml compose.jsonnet` because YAML is a superset of JSON).

[jsonnet]: https://jsonnet.org/
[yq]: https://kislyuk.github.io/yq/
