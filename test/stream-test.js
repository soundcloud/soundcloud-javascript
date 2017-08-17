describe('SDK streaming', function () {
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

  it('should only add a secret token to the url if given', function () {
    var secretToken = '123';
    SC.stream('/tracks/cool-track');
    assert(this.requests[0].url.indexOf('secret_token') === -1);

    SC.stream('/tracks/cool-track', secretToken);
    assert(this.requests[1].url.indexOf('secret_token') !== -1);
    assert(this.requests[1].url.indexOf(secretToken) !== -1);
  });

  it('should create a player object', function(done){
    SC.stream('/tracks/cool-track').then(function(player){
      assert.ok(player);
      assert.ok(player.play);
      assert.ok(player.pause);
      done();
    }).catch(function(e){
      done(e);
    });
    this.requests[0].respond(200,
                             { 'Content-Type': 'text/json' },
                             '{"id": 123, "duration": 23}');
  });
});
