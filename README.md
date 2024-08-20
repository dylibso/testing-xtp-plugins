# Testing XTP Plugins with Host Functions

## Repository Overview

### `mock`

This directory contains the implementation of the mocked host functions. Note
that these functions are Extism plugin exports, which become imports to the
plugin that calls the host functions.

### `plugin`

This directory contains an example XTP plugin, based on the `schema.yaml`
schema. It calls the host functions from its export `handleLogEvent` and
aggregates the count of events per event source. We test this plugin's behavior
and the host function integration by running it several times with different
inputs to see that the KV data and plugin aggregation of that data is correct.

### `test`

This directory contains the test code that calls into the code in `plugin` to
test various aspects of it.

## Building

Before compiling the contents, please ensure that you have the following
installed:

- [`xtp`](https://docs.xtp.dylibso.com/docs/cli#installation) (any recent
  version)
- [`tinygo`](https://tinygo.org/getting-started/install/) (>= 0.31.2)
- [`zig`](https://ziglang.org/) (>= 0.13.0)
- [`extism-js`](https://github.com/extism/js-pdk?tab=readme-ov-file#install-the-compiler)
  (>= 1.0.0-rc11)
- [`npm`](https://nodejs.org) (>= 10.2.4)

With all of the above installed, you can now run:

```sh
make build
```

## Testing

After you've built the `mock`, `plugin` and `test` modules, you can run:

```sh
make test
```

or:

```sh
cd plugin
xtp plugin test # note: the plugin/xtp.toml [[test]] configuration
```

## Questions or need help?

File [an issue](https://github.com/dylibso/testing-xtp-plugins/issues) on this
repository, or reach out to us on the
[Extism Discord](https://extism.org/discord) and we can provide assistance.
