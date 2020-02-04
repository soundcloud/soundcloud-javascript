const BackboneEvents = require('backbone-events-standalone');
const { errors: { PlayerFatalError }, State } = require('../vendor/playback/playback').MaestroCore;
const { errors: { NoStreamsError, NotSupportedError } } = require('../vendor/playback/playback').SCAudio;

const TIMEUPDATE_INTERVAL = 1000 / 60;

module.exports = function(scaudioPlayer) {
  function getState() {
    switch (scaudioPlayer.getState()) {
      case State.PLAYING:
        return 'playing';
      case State.PAUSED:
        return scaudioPlayer.isEnded() ? 'ended' : 'paused';
      case State.DEAD:
        return scaudioPlayer.getFatalError() ? 'error' : 'dead';
      case State.LOADING:
      default:
        return 'loading';
    }
  }

  function handleEmittingTimeEvents() {
    let timerId = 0;
    let previousPosition = null;
    scaudioPlayer.onChange.subscribe(({ playing, seeking, dead }) => {
      if (!window) return;
      if (dead) {
        window.clearTimeout(timerId);
      } else if (playing !== undefined || seeking !== undefined) {
        doEmit();
      }
    });
    function doEmit() {
      if (!window) return;
      window.clearTimeout(timerId);
      if (scaudioPlayer.isPlaying() && !scaudioPlayer.isEnded()) {
        timerId = window.setTimeout(doEmit, TIMEUPDATE_INTERVAL);
      }
      const newPosition = scaudioPlayer.getPosition();
      if (newPosition !== previousPosition) {
        previousPosition = newPosition;
        playerApi.trigger('time', newPosition);
      }
    }
  }
  let hadFirstPlay = false;
  scaudioPlayer.onStateChange.subscribe(() => playerApi.trigger('state-change', getState()));
  scaudioPlayer.onPlay.subscribe(() => {
    playerApi.trigger(hadFirstPlay ? 'play-resume' : 'play-start');
    hadFirstPlay = true;
  });

  scaudioPlayer.onPlayIntent.subscribe(() => playerApi.trigger('play'));
  scaudioPlayer.onPlayRejection.subscribe((playRejection) => playerApi.trigger('play-rejection', playRejection));
  scaudioPlayer.onPauseIntent.subscribe(() => playerApi.trigger('pause'));
  scaudioPlayer.onSeek.subscribe(() => playerApi.trigger('seeked'));
  scaudioPlayer.onSeekRejection.subscribe((seekRejection) => playerApi.trigger('seek-rejection', seekRejection));
  scaudioPlayer.onLoadStart.subscribe(() => playerApi.trigger('buffering_start'));
  scaudioPlayer.onLoadEnd.subscribe(() => playerApi.trigger('buffering_end'));
  scaudioPlayer.onEnded.subscribe(() => playerApi.trigger('finish'));
  scaudioPlayer.onError.subscribe((error) => {
    if (error instanceof NoStreamsError) {
      playerApi.trigger('no_streams');
    } else if (error instanceof NotSupportedError) {
      playerApi.trigger('no_protocol');
    } else if (error instanceof PlayerFatalError) {
      playerApi.trigger('audio_error');
    }
  });

  const playerApi = {
    play: scaudioPlayer.play.bind(scaudioPlayer),
    pause: scaudioPlayer.pause.bind(scaudioPlayer),
    seek: scaudioPlayer.seek.bind(scaudioPlayer),
    getVolume: scaudioPlayer.getVolume.bind(scaudioPlayer),
    setVolume: scaudioPlayer.setVolume.bind(scaudioPlayer),
    currentTime: scaudioPlayer.getPosition.bind(scaudioPlayer),
    getDuration: scaudioPlayer.getDuration.bind(scaudioPlayer),
    isBuffering: scaudioPlayer.isLoading.bind(scaudioPlayer),
    isPlaying: scaudioPlayer.isPlaying.bind(scaudioPlayer),
    isActuallyPlaying: scaudioPlayer.isActuallyPlaying.bind(scaudioPlayer),
    isEnded: scaudioPlayer.isEnded.bind(scaudioPlayer),
    isDead: scaudioPlayer.isDead.bind(scaudioPlayer),
    kill: scaudioPlayer.kill.bind(scaudioPlayer),
    hasErrored: () => !!scaudioPlayer.getFatalError(),
    getState
  };
  BackboneEvents.mixin(playerApi);
  handleEmittingTimeEvents();
  return playerApi;
}
