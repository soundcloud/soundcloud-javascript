# SoundCloud JavaScript SDk
## Introduction

The JavaScript SDK lets you easily integrate SoundCloud into your website or webapp. 
The full documentation can be found [here](http://developers.soundcloud.com/docs/javascript-sdk).
This README provides development related informations.

## Repository Structure
- _build/development_ contains the development build
- _build/release_ contains the minified release build
- _src/_ the coffee script source code
- _vendor/_ includes git submodules of external projects
- _test/_ tests
- _examples/_ examples

## Development Dependencies

- Google Closure Compiler
- CoffeeScript

## Build

To build the release version in build/ just run:

    $ make build

## Testing

To run the tests just start an HTTP server (for example "$ ponyhost server") in the project root and navigate to http://yourhost/test/test.html.
In development mode the tests will automatically compile the coffeescript on each reload.
In build mode the tests will laod the compiled sdk.js.
