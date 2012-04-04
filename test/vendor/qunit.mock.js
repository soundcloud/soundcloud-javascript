(function() {
  var expectCall, finishMock, mock, mocked, mocking, stack, stub, testExpectations, expectCallWithArgumentsAndStub, expectCallAndStub;
  var __slice = Array.prototype.slice;
  mocking = null;
  stack = [];
  expectCall = function(object, method, calls) {
    var expectation;
    calls = (typeof calls !== "undefined" && calls !== null) ? calls : 1;
    expectation = {
      object: object,
      method: method,
      expectedCalls: calls,
      originalMethod: object[method],
      callCount: 0
    };
    object[method] = function() {
      var args;
      args = __slice.call(arguments, 0);
      expectation.callCount += 1;
      return expectation.originalMethod.apply(object, args);
    };
    return mocking.expectations.push(expectation);
  };

  stub = function(object, method, fn) {
    var stb;
    stb = {
      object: object,
      method: method,
      original: object[method]
    };
    object[method] = fn;
    return mocking.stubs.push(stb);
  };

  expectCallAndStub = function(obj, method, calls, fn){
    if(fn === undefined){
      fn = calls;
      calls = 1;
    }

    stub(obj, method, fn);
    expectCall(obj, method, calls);
  };

  expectCallWithArgumentsAndStub = function(obj, method, expectedArguments, fn){
    stub(obj, method, function(){
      argumentsArray = Array.apply(null, arguments)
      deepEqual(argumentsArray, expectedArguments, "Expected arguments for " + method + "() don't match:");

      if(fn){
        return fn.apply(this, argumentsArray);
      }
    });
    expectCall(obj, method);
  };

  mock = function(test) {
    var mk;
    mk = {
      expectations: [],
      stubs: []
    };
    mocking = mk;
    stack.push(mk);
    test();
    return !(QUnit.config.blocking) ? finishMock() : QUnit.config.queue.unshift(finishMock);
  };
  mocked = function(fn) {
    return function() {
      return mock(fn);
    };
  };
  finishMock = function() {
    testExpectations();
    stack.pop();
    return (mocking = stack.length > 0 ? stack[stack.length - 1] : null);
  };
  testExpectations = function() {
    var _a, expectation, stb;
    while (mocking.expectations.length > 0) {
      expectation = mocking.expectations.pop();
      equal(expectation.callCount, expectation.expectedCalls, "method " + (expectation.method) + " should be called " + (expectation.expectedCalls) + " times");
      expectation.object[expectation.method] = expectation.originalMethod;
    }
    _a = [];
    while (mocking.stubs.length > 0) {
      _a.push((function() {
        stb = mocking.stubs.pop();
        return (stb.object[stb.method] = stb.original);
      })());
    }
    return _a;
  };
  window.expectCall = expectCall;
  window.expectCallAndStub = expectCallAndStub;
  window.expectCallWithArgumentsAndStub = expectCallWithArgumentsAndStub;
  window.stub = stub;
  window.mock = mock;
  window.QUnitMock = {
    mocking: mocking,
    stack: stack
  };
  window.test = function() {
    var _a, _b, arg, args, i;
    args = __slice.call(arguments, 0);
    _a = args;
    for (i = 0, _b = _a.length; i < _b; i++) {
      arg = _a[i];
      if ($.isFunction(arg)) {
        args[i] = mocked(arg);
      }
    }
    return QUnit.test.apply(this, args);
  };
  window.asyncTest = function(testName, expected, callback) {
    if (arguments.length === 2) {
      callback = expected;
      expected = 0;
    }
    return QUnit.test(testName, expected, mocked(callback), true);
  };
})();