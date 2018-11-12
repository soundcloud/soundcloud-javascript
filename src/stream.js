const api = require('./api');
const config = require('./config');
const playerApi = require('./player-api');
const SCAudio = require('../vendor/playback/playback').SCAudio;
const maestroLogger = require('../vendor/playback/playback').MaestroCore.logger;
const StreamUrlRetriever = require('../vendor/playback/playback').SCAudioPublicApiStreamURLRetriever.StreamUrlRetriever;
const MediaElementManager = require('../vendor/playback/playback').SCAudioControllerHTML5Player.MediaElementManager;
const HTML5PlayerController = require('../vendor/playback/playback').SCAudioControllerHTML5Player.HTML5PlayerController;
const HLSMSEPlayerController = require('../vendor/playback/playback').SCAudioControllerHLSMSEPlayer.HLSMSEPlayerController;
const stringLoader = require('../vendor/playback/playback').MaestroLoaders.stringLoader;

const mediaElementManager = new MediaElementManager('audio', maestroLogger.noOpLogger);

/**
 * Fetches track info and instantiates a player for the track
 * @param  {String} trackPath   The track's path (/tracks/:track_id)
 * @param  {String=} secretToken If the track is secret, provide the secret token here
 * @return {Promise}
 */
module.exports = (trackPath, secretToken) => {
  const options = secretToken ? {secret_token: secretToken} : {};

  return api.request('GET', trackPath, options).then((track) => {
    function registerPlay() {
      let registerEndpoint = `${baseURL}/tracks/${encodeURIComponent(track.id)}/plays?client_id=${encodeURIComponent(clientId)}`;
      if (secretToken) {
        registerEndpoint += `&secret_token=${encodeURIComponent(secretToken)}`;
      }
      const xhr = new XMLHttpRequest();
      xhr.open('POST', registerEndpoint, true);
      xhr.send();
    }

    const baseURL = config.get('baseURL')
    const clientId = config.get('client_id');
    const oauthToken = config.get('oauth_token');

    let playRegistered = false;
    const streamUrlRetriever = new StreamUrlRetriever({
      clientId,
      secretToken,
      trackId: track.id,
      requestAuthorization: oauthToken ? 'OAuth ' + oauthToken : null,
      loader: stringLoader
    });

    const player = new SCAudio.Player({
      controllers: [
        new HLSMSEPlayerController(mediaElementManager),
        new HTML5PlayerController(mediaElementManager)
      ],
      streamUrlRetriever,
      getURLOpts: { preview: track.policy === 'SNIP' },
      streamUrlsExpire: true,
      mediaSessionEnabled: true,
      logger: maestroLogger.noOpLogger
    });

    player.onPlay.subscribe(() => {
      if (!playRegistered) {
        playRegistered = true;
        registerPlay();
      }
    });
    player.onEnded.subscribe(() => {
      // maestro keeps the old playing state when at the end. Call pause() to maintain backwards compatibility
      player.pause();
    });
    player.onPlayIntent.subscribe(() => {
      if (player.isEnded()) {
        // seek back to 0 if the user calls play() and we're at the end.
        player.seek(0);
      }
    });
    return playerApi(player);
  });
};

/**
 * Call this from a user interaction, before creating a player, to ensure that playback
 * can start even if `play()` is not from a user interaction.
 */
module.exports.activateAudioElement = () => {
  mediaElementManager.activate();
};
