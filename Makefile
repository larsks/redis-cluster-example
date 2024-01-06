%.json: %.jsonnet
	jsonnet -o $@ $<

%.yaml: %.json
	yq -y < $< > $@ || { rm -f $@; exit 1; }

compose.yaml: compose.jsonnet redisnode.libsonnet

clean:
	rm -f compose.yaml
