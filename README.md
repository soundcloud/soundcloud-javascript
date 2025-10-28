# ⚠️⚠️DEPRECATED - NO LONGER MAINTAINED⚠️⚠️
This repository is no longer maintained by the SoundCloud team due to capacity constraints. We're instead focusing our efforts on improving the API & the developer platform. Please note, at the time of updating this, the repo is already not in sync with the latest API changes. 


---

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

