.PHONY: build test

build: build-host-mock build-plugin build-test

test: build
	# can run from root as:
	# xtp plugin test plugin/zig-out/bin/plugin.wasm --with test/dist/plugin.wasm --mock-host mock/host.wasm --mock-input-file mock-input.json
	# or using xtp.toml config:
	@cd plugin && xtp plugin test


build-host-mock:
	@cd mock && tinygo build -target wasi -o host.wasm host.go

build-plugin:
	@cd plugin && xtp plugin build

build-test:
	@cd test && npm i && npm run build