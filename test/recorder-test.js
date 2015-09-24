var Recorder = SC.Recorder;

var AudioContext = window.AudioContext || window.webkitAudioContext;
var context;
if (AudioContext) {
  context = new AudioContext();
}

var testRecorder = function(){
  return new Recorder({
    source: context.createBufferSource()
  });
};

// returns a silent oscillator
var silentOscillator = function(){
  var osc = context.createOscillator();
  var gain = context.createGain();
  gain.gain.value = 0;
  osc.connect(gain);
  gain.connect(context.destination);
  return osc;
};

describe('Recorder', function () {
  if (!AudioContext) {
    console.log('Browser does not support the Web Audio API, will skip Recorder tests.');
    return;
  }

  it('should initialize properly', function () {
    var options = {
      context: {},
      source: {}
    };

    var recorder = new Recorder(options);

    assert.equal(recorder.context, options.context, 'uses the provided context');
    assert.equal(recorder.source, options.source, 'uses the provided source');
  });

  describe('start', function(){
    it('should start the recording', function(done){
      var recorder = testRecorder();
      return recorder.start().then(function(){
        assert.ok(recorder._recorder, 'instantiated the recorder');
        done();
      }).catch(function(err){
        done(err);
      });
    });

    it('should throw an error if the source is not valid', function(done){
      var recorder = new Recorder({
        source: {}
      });
      recorder.start().then(function(){
        assert.fail('It should not go to `then`');
        done()
      }).catch(function(err){
        assert.ok(true);
        done();
      });
    });
  });

  describe('recording', function(){
    it('should return a buffer', function(done){
      var osc = silentOscillator();
      var recorder = new Recorder({
        context: context,
        source: osc
      });
      osc.start(0);

      recorder.start().then(function(){
        setTimeout(function(){
          recorder.stop();
          osc.stop(0);
          recorder.getBuffer().then(function(buffer){
            assert.ok(buffer instanceof AudioBuffer, 'provides a valid buffer');
            done();
          }).catch(function(err){
            done(err);
          })
        }, 500);
      });
    });

    it('should return a wav', function(done){
      var osc = silentOscillator();
      var recorder = new Recorder({
        context: context,
        source: osc
      });
      osc.start(0);

      recorder.start().then(function(){
        setTimeout(function(){
          recorder.stop();
          osc.stop(0);
          recorder.getWAV().then(function(wav){
            assert.ok(wav instanceof Blob, 'provides a valid wav blob');
            done();
          }).catch(function(err){
            done(err);
          })
        }, 500);
      });
    });

    it('should fail if recording has not started', function(done){
      var osc = silentOscillator();
      var recorder = new Recorder({
        context: context,
        source: osc
      });
      osc.start(0);

      setTimeout(function(){
        recorder.stop();
        osc.stop(0);
        return recorder.getBuffer().catch(function(){
          done();
        });
      }, 500);
    });
  });

  describe('play', function(){
    it('should play the recording', function(done){
      var osc = silentOscillator();
      var recorder = new Recorder({
        context: context,
        source: osc
      });
      osc.start(0);

      recorder.start().then(function(){
        setTimeout(function(){
          recorder.stop();
          osc.stop(0);
          recorder.play().then(function(node){
            assert.ok(node instanceof AudioBufferSourceNode);
            done();
          }).catch(function(err){
            done(err);
          });
        }, 500);
      });
    });
  });
});
