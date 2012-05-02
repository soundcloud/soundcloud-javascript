module("SC.Helper.merge")

test "Shallow merge 2 objects with the 2nd taking precedence", () ->
  deepEqual SC.Helper.merge({x: 1, y: 2, z: 3}, {z: 1}), {x: 1, y: 2, z: 1}

test "Shallow merge 2 arrays", () ->
  deepEqual SC.Helper.merge([1, 2, 3], [4, 5]), [1, 2, 3, 4, 5]

module "SC.Helper.groupBy"

test "It should group objects by a property", ->
  collection = [{a: 1}, {a: 1}, {a: 2}, {a: 2}, {a: 2}, {a: null}]
  expected =
    "1": [{a: 1}, {a: 1}]
    "2": [{a: 2}, {a: 2}, {a: 2}]
  deepEqual SC.Helper.groupBy(collection, "a"), expected

module "SC.Helper.extractOptionsAndCallbackArguments"
test "passing only a callback", ->
  fn = (new Function)
  a = SC.Helper.extractOptionsAndCallbackArguments(fn)
  deepEqual(a.options, {})
  equal(a.callback, fn)

test "passing options and callback", ->
  fn = (new Function)
  options = {a: 1}
  a = SC.Helper.extractOptionsAndCallbackArguments(options, fn)
  deepEqual(a.options, options)
  equal(a.callback, fn)

test "passing only options", ->
  options = {a: 1}
  a = SC.Helper.extractOptionsAndCallbackArguments(options)
  deepEqual(a.options, options)
  equal(a.callback, undefined)

test "passing nothing", ->
  a = SC.Helper.extractOptionsAndCallbackArguments()
  deepEqual(a.options, {})
  equal(a.callback, undefined)
