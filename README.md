# SoundCloud JavaScript SDk
## Introduction

The SoundCloud JavaScript SDK lets you easily integrate SoundCloud into your website or web app. 
It's full documentation can be found [here](http://developers.soundcloud.com/docs/javascript-sdk).
In most case it's highly recommended that you use the hosted version from [http://connect.soundcloud.com/sdk.js](http://connect.soundcloud.com/sdk.js) in your website. This README provides development related informations.


## Dependencies

- npm
- - coffee-script
- - uglify-js
- - jslint

## Usage

To checkout the repository locally and to initialize all submodules in vendor run:

    $ git clone git@github.com:soundcloud/soundcloud-javascript.git
    $ cd soundcloud-javascript
    $ git submodule update --init
    $ npm install

To build the release version in _build/_ just run:

    $ make build

To run the tests or use the sdk.js  you can run _bin/server_ in either ./ or in ./build.
The sdk.js in ./ will automatically compile all the coffeescripts in ./src on the fly when loaded. 
To make the sdk.js fully work it needs to be accessed via http://connect.soundcloud.dev instead of http://localhost:9090

## Testing

To run the tests just start an HTTP server (for example "$ ponyhost server") in the project root and navigate to http://yourhost/test/test.html.
In development mode the tests will automatically compile the coffeescript on each reload.
In build mode the tests will laod the compiled sdk.js.

## Repository Structure

- _build/_ will provide the compiled CoffeeScript as it's hosted on [http://connect.soundcloud.com](http://connect.soundcloud.com)
- _src/_ the coffee script source code
- _vendor/_ includes git submodules of external projects
- _test/_ tests
- _examples/_ examples

