describe('API methods', function () {
  beforeEach(function () {
    this.xhr = sinon.useFakeXMLHttpRequest();

    this.requests = [];
    this.xhr.onCreate = function(xhr) {
      this.requests.push(xhr);
    }.bind(this);

    SC.initialize({
      client_id: 'YOUR_CLIENT_ID',
      redirect_uri: 'http://localhost:8080'
    });
  });

  afterEach(function() {
    this.xhr.restore();
  });

  it('should return the request with the promise', function(){
    var promise = SC.get('tracks/its-a-deep-bark');
    assert.isNotNull(promise.request);
    assert.instanceOf(promise.request, XMLHttpRequest);
  });

  it('should return the correct status if a request has an empty response', function(done){
    SC.get('tracks/its-a-deep-bark342').then(function(){
      assert.fail();
      done()
    }).catch(function(error){
      assert.equal(error.status, 404);
      assert.equal(error.message, 'HTTP Error: 404');
      done();
    });
    this.requests[0].respond(404,
                             { 'Content-Type': 'text/json' },
                             '');
  });

  describe('GET calls', function () {
    it('should make a GET against tracks', function (done) {
      SC.get('tracks/its-a-deep-bark').then(function (track) {
        assert.equal(track.kind, 'track', 'track GET returns a track');
        assert.equal(this.requests[0].method, 'GET');
        done();
      }.bind(this)).catch(function (err) {
        done(err);
      });
      this.requests[0].respond(200,
                               { 'Content-Type': 'text/json' },
                               '{"kind": "track"}');
    });

    it('should trigger a promise catch on a 500 with bad JSON', function (done) {
      SC.get('tracks/its-a-deep-bark').then(function (track) {
        assert.fail('Promise should not resolve');
        done();
      }.bind(this)).catch(function (err) {
        assert.ok(err, 'Promise.catch is sent an error object');
        assert.equal(err.status, 500, 'error.status is a 500');
        done();
      });
      this.requests[0].respond(500,
                               { 'Content-Type': 'text/json' },
                               '{"errors": [{"error_message": "server explosion"}]');
    });

    it('should trigger a promise catch on a 500 with error JSON', function (done) {
      SC.get('tracks/its-a-deep-bark').then(function (track) {
        assert.fail('Promise should not resolve');
        done();
      }.bind(this)).catch(function (err) {
        assert.ok(err, 'Promise.catch is sent and error object');
        assert.equal(err.status, 500, 'error.status is a 500');
        assert.equal(err.message, 'server explosion');
        done();
      });
      this.requests[0].respond(500,
                               { 'Content-Type': 'text/json' },
                               '{"errors": [{"error_message": "server explosion"}]}');
    });

    it('should trigger a promise catch on a 404', function (done) {
      SC.get('tracks/its-a-deep-bark').then(function (track) {
        assert.fail('Promise should not resolve');
        done();
      }.bind(this)).catch(function (err) {
        assert.ok(err, 'Promise.catch is sent and error object');
        assert.equal(err.status, 404, 'error.status is a 404');
        assert.equal(err.message, 'not found');
        done();
      });
      this.requests[0].respond(404,
                               { 'Content-Type': 'text/json' },
                               '{"errors": [{"error_message": "not found"}]}');
    });

    it('should use the oauth_token if it is set', function (done) {
      SC.initialize({
        client_id: 'YOUR_CLIENT_ID',
        redirect_uri: 'http://localhost:8080',
        oauth_token: 'SOME_OAUTH_TOKEN'
      });

      SC.get('tracks/its-a-deep-bark').then(function (track) {
        done();
      }.bind(this)).catch(function (err) {
        done();
      });

      assert.match(this.requests[0].url, /oauth_token=SOME_OAUTH_TOKEN/, 'ouath token exists in URL');
      assert.notMatch(this.requests[0].url, /client_id=YOUR_CLIENT_ID/, 'client id does not exist in URL');
      this.requests[0].respond(404,
                               { 'Content-Type': 'text/json' },
                               '{"errors": [{"error_message": "not found"}]}');
    });

  });

  it('should add the oauth_token to the query for non GET requests', function (done) {
    SC.initialize({
      client_id: 'YOUR_CLIENT_ID',
      redirect_uri: 'http://localhost:8080',
      oauth_token: 'SOME_OAUTH_TOKEN'
    });

    SC.put('tracks').then(function (track) {
      done();
    });

    assert.match(this.requests[0].url, /oauth_token=SOME_OAUTH_TOKEN/, 'ouath token exists in URL');
    assert.notMatch(this.requests[0].url, /client_id=YOUR_CLIENT_ID/, 'client id does not exist in URL');
    this.requests[0].respond(200, { 'Content-Type': 'text/json' }, '{}');
  });

  it('should make a POST when post is called', function (done) {
    SC.post('posting', {foo: 'bar'}).then(function (res) {
      assert.equal(this.requests[0].method, 'POST');
      done();
    }.bind(this)).catch(function (err) {
      done(err);
    });
    this.requests[0].respond(200,
                             { 'Content-Type': 'text/json' },
                             '{"kind": "track"}');
  });


  it('should make a PUT when put is called', function (done) {
    SC.put('putting', {foo: 'bar'}).then(function (res) {
      assert.equal(this.requests[0].method, 'PUT');
      done();
    }.bind(this)).catch(function (err) {
      done(err);
    });
    this.requests[0].respond(200,
                             { 'Content-Type': 'text/json' },
                             '{"kind": "track"}');
  });

  it('should make a DELETE when delete is called', function (done) {
    SC['delete']('deleting', {foo: 'bar'}).then(function (res) {
      assert.equal(this.requests[0].method, 'DELETE');
      done();
    }.bind(this)).catch(function (err) {
      done(err);
    });
    this.requests[0].respond(200,
                             { 'Content-Type': 'text/json' },
                             '{"status": "200 - OK"}');
  });

  describe('UPLOAD', function(){
    if (!window.FormData) {
      console.log('Browser does not support FormData, will skip upload tests.');
      return;
    }

    it('should send FormData for uploads', function(){
      SC.initialize({
        client_id: 'YOUR_CLIENT_ID',
        redirect_uri: 'http://localhost:8080',
        oauth_token: 'THE_TOKEN'
      });

      SC.upload({asset_data: {}, title: {}});
      assert.ok(this.requests[0].requestBody instanceof FormData);
    });

    it('should allow `file` instead of asset_data', function(){
      SC.initialize({
        client_id: 'YOUR_CLIENT_ID',
        redirect_uri: 'http://localhost:8080',
        oauth_token: 'THE_TOKEN'
      });

      SC.upload({file: {}, title: {}});
      assert.ok(this.requests[0].requestBody instanceof FormData);
    });

    it('should fail if not all needed params specified', function(done){
      SC.upload({title: {}}).then(function(){
        assert.fail();
        done();
      }).catch(function(){
        assert.ok(true);
        done();
      });
    });
  });

  describe('resolve', function(){
    it('should resolve URLs properly', function(){
      var url = 'https://soundcloud.com/dj-perun/its-a-deep-bark';
      SC.resolve(url);
      var requestUrl = decodeURIComponent(this.requests[0].url);
      var urlPart = requestUrl.split('url=')[1].split('&')[0];
      assert.ok(urlPart === url, 'The URL in the request should match the original URL');
      assert.ok(requestUrl.indexOf('&_status_code_map[302]=200') >= 0, 'Should be mapping a 302 to a 200');
    });
  });
});
