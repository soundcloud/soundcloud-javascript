# SoundCloud JavaScript Next

## Setup

- `make setup`

This will install the right node version locally. Please be patient. :)

## Building source

- `make build`

By default, the SDK is built into `build/sdk/sdk-VERSION.js`. Take a look at `webpack.config.js` for details.

### Running with the watcher

This will run webpack with a watcher. The sdk will be rebuilt when you save changes in `src`.

In addition, webpack will start a development server on `http://localhost:8080/`. This serves the files in the `examples/` folder.

- `make run-with-watcher`

### Running without the watcher (custom server)

- `make run`

## Running tests

- `make test`

The test suite uses Karma to execute the tests in Chrome, Firefox, and Safari if available.

