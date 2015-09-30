# SoundCloud JavaScript Next

## Documentation

https://developers.soundcloud.com/docs/api/sdks#javascript

## Building source

- `make build`

This will build and install node from source. Please be patient. :)

By default, the SDK is built into `build/sdk/sdk-VERSION.js`. Take a look at `webpack.config.js` for details.

### Building with the watcher

- `npm start`

This will run webpack with a watcher. The sdk will be rebuilt when you save changes in `src`.

In addition, webpack will start a development server on `http://localhost:8080/`. This serves the files in the `examples/` folder.

## Running tests

- `make test`

The test suite uses Karma to execute the tests in Chrome, Firefox, and Safari if available.

