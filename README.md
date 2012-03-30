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

## Tasks

Will build the development in build/development

    $ rake build

Will build the minified release in build/release

    $ rake build TARGET=release




