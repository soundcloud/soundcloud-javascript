const audioContext = require('./audiocontext');
const getUserMedia = require('./getusermedia');
const Promise = require('es6-promise').Promise;
const RecorderJS = require('../../vendor/recorderjs/recorder');


/**
 * Sets up the source node by either returning the provided source
 * or by requesting access to the browser's microphone
 * @return {Promise.<AudioNode>} The AudioNode that has been set up
 */
const initSource = function() {
  const context = this.context;

  // if a source was passed, use it, otherwise, request it
  return new Promise((resolve, reject) => {
    if (this.source) {
      if (!(this.source instanceof AudioNode)) {
        reject(new Error('source needs to be an instance of AudioNode'));
      } else {
        resolve(this.source);
      }
    } else {
      getUserMedia({audio: true}, ((stream) => {
        this.stream = stream;
        this.source = context.createMediaStreamSource(stream);
        resolve(this.source);
      }).bind(this), reject);
    }
  });
}

/**
 * Uses the Web Audio API to record audio and to play it.
 * Also leverages the internal api module to upload recordings
 */
class Recorder {

  /**
   * Initializes the Recorder
   * @param {Object=}      options
   * @param {AudioContext} options.context The AudioContext to use for recording
   * @param {AudioNode}    options.source  An AudioNode that should be used for recording
   */
  constructor (options = {}) {
    this.context = options.context || audioContext();
    this._recorder = null;
    this.source = options.source;
    this.stream = null;
  }

  /**
   * Starts the recording from the browser's microphone or
   * form the `source` that was provided in the constructor.
   * @return {Promise.<AudioNode>} The AudioNode that is used for recording
   */
  start () {
    return initSource.call(this).then((source) => {
      this._recorder = new RecorderJS(source);
      this._recorder.record();
      return source;
    });
  }

  /**
   * Stops the recording
   */
  stop () {
    // stop the recording
    if (this._recorder) {
      this._recorder.stop();
    }

    // stop the input media stream
    if (this.stream) {
      this.stream.stop();
    }
  }

  /**
   * Creates a buffer from the recording
   * @return {Promise.<AudioBuffer>} The AudioBuffer
   */
  getBuffer () {
    return new Promise((resolve, reject) => {
      if (this._recorder) {
        this._recorder.getBuffer(((buffer) => {
          const sampleRate = this.context.sampleRate;
          const theBuffer = this.context.createBuffer(2, buffer[0].length, sampleRate);
          theBuffer.getChannelData(0).set(buffer[0]);
          theBuffer.getChannelData(1).set(buffer[1]);
          resolve(theBuffer);
        }).bind(this));
      } else {
        reject(new Error('Nothing has been recorded yet.'));
      }
    });
  }

  /**
   * Creates a WAV blob from the recording
   * @return {Promise.<Blob>} The recording as a WAV Blob
   */
  getWAV () {
    return new Promise((resolve, reject) => {
      if (this._recorder) {
        this._recorder.exportWAV((blob) => {
          resolve(blob);
        });
      } else {
        reject(new Error('Nothing has been recorded yet.'));
      }
    });
  }

  /**
   * Plays the recording
   * @return {Promise.<BufferSourceNode>} The AudioNode that is used to play the recording
   */
  play () {
    return this.getBuffer().then((buffer) => {
      const bufferSource = this.context.createBufferSource();
      bufferSource.buffer = buffer;
      bufferSource.connect(this.context.destination);
      bufferSource.start(0);
      return bufferSource;
    });
  }

  /**
   * Initiates the download of the wav file
   * @param  {[type]} filename [description]
   * @return {[type]}          [description]
   */
  saveAs (filename) {
    return this.getWAV().then((blob) => {
      RecorderJS.forceDownload(blob, filename);
    });
  }

  /**
   * Deletes and stops the recording
   */
  delete () {
    if (this._recorder) {
      this._recorder.stop();
      this._recorder.clear();
      this._recorder = null;
    }

    if (this.stream) {
      this.stream.stop();
    }
  }
}

module.exports = Recorder;
