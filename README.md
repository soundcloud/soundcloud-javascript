# SoundCloud JavaScript SDK
## Introduction

The [SoundCloud JavaScript SDK](http://developers.soundcloud.com/docs/javascript-sdk) lets you easily integrate SoundCloud into your website or web app.

**In most cases it's highly recommended that you use the hosted version** from [http://connect.soundcloud.com/sdk.js](http://connect.soundcloud.com/sdk.js) in your website. This README provides development-related information.

## Dependencies

- npm
- - coffee-script
- - uglify-js
- - jslint

## Development

To check out the repository locally and initialize all submodules in `vendor/`, run:

```bash
$ git clone git@github.com:soundcloud/soundcloud-javascript.git
$ cd soundcloud-javascript
$ git submodule update --init
$ npm install
```

To build the release version in `build/`, just run:

```bash
$ make build
```

To run the tests or use `sdk.js`, run this from either the top level of your repo or `build/`:

```bash
$ bin/server
```

The file `sdk.js` will automatically compile all coffeescript files in `src/` on the fly when loaded.
For `sdk.js` to work **it must be accessed from `http://connect.soundcloud.dev`** instead of `http://localhost:9090`.

## Testing

To run the tests, just start an HTTP server in the project root and navigate to `http://yourhost/test/test.html`.
In development mode the tests will automatically compile the coffeescript on each reload.
In build mode the tests will laod the compiled sdk.js.

## Repository Structure

- `build/` — contains compiled JS (as it's hosted on [http://connect.soundcloud.com](http://connect.soundcloud.com))
- `src/` — contains coffeescript source code
- `vendor/` — includes git submodules of external projects
- `test/` — tests live here
- `examples/` — here there be examples
