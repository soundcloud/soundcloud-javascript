const AudioContext = global.AudioContext || global.webkitAudioContext;
let context = null;

module.exports = () => {
  return context ? context : (context = new AudioContext());
};
