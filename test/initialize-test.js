describe('SDK initialize', function () {
  it('should make isConnected true when oauth_token is set', function () {
    SC.initialize({
      oauth_token: 'oauth_token'
    });

    assert.ok(SC.isConnected());
  });
});
