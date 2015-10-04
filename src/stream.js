const api = require('./api');
const AudioManager = require('../vendor/audiomanager');
const audioManager = new AudioManager({
  flashAudioPath: 'https://connect.soundcloud.com/sdk/flashAudio.swf'
});
const config = require('./config');
const SCAudio = require('../vendor/scaudio');

/**
 * Fetches track info and instantiates a player for the track
 * @param  {String} trackPath   The track's path (/tracks/:track_id)
 * @param  {String=} secretToken If the track is secret, provide the secret token here
 * @return {Promise}
 */
module.exports = (trackPath, secretToken) => {
  const options = secretToken ? {secret_token: secretToken} : {};

  return api.request('GET', trackPath, options).then((track) => {
    const baseURL = config.get('baseURL')
    const clientId = config.get('client_id');

    let streamsEndpoint = `${baseURL}/tracks/${track.id}/streams?client_id=${clientId}`;
    let registerEndpoint = `${baseURL}/tracks/${track.id}/plays?client_id=${clientId}`;

    if (secretToken) {
      streamsEndpoint += `&secret_token=${secretToken}`;
      registerEndpoint += `&secret_token=${secretToken}`;
    }

    return new SCAudio(audioManager, {
      soundId: track.id,
      duration: track.duration,
      streamUrlsEndpoint: streamsEndpoint,
      registerEndpoint: registerEndpoint
    });
  });
};
