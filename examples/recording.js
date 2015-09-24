SC.initialize({
  client_id: 'YOUR_CLIENT_ID',
  redirect_uri: 'http://localhost:8080'
});

// background video
var getUserMedia = navigator.getUserMedia ||
                   navigator.webkitGetUserMedia ||
                   navigator.mozGetUserMedia;
var URL = window.URL || window.webkitURL;
var audioContext = new (AudioContext || webkitAudioContext || mozAudioCntext)();
var video = document.getElementById('video');
var recording = document.getElementById('recording');
var height, userMediaStream, width;

// record flow
var recorder;
var startRecording = function(){
  recording.classList.add('visible');
  if (recorder) {
    recorder.stop();
  }
  var streamSource = audioContext.createMediaStreamSource(userMediaStream);
  recorder = new SC.Recorder({source: streamSource});
  recorder.start();
};

var stopRecording = function(){
  recording.classList.remove('visible');
  if (recorder) {
    recorder.stop();
    takePicture();
  }
};

video.addEventListener('mousedown', startRecording);
video.addEventListener('touchstart', startRecording);
video.addEventListener('mouseup', stopRecording);
video.addEventListener('touchend', stopRecording);

// get the user's camera feed
getUserMedia.call(navigator, {video: true, audio: true}, function(stream){
  userMediaStream = stream;
  // convert stream to video feed and play it
  video.src = URL.createObjectURL(stream);
  video.play();
  video.volume = 0;
}, function(error){
  alert('There was a problem in getting the video and audio stream from your device. Did you block the access?');
});

// read the video height when it is playing
video.addEventListener('canplay', function(){
  if (!width || !height) {
    width = canvas.width = video.videoWidth;
    height = canvas.height = video.videoHeight;
  }
});

// take picture and upload
var takePicture = function(){
  var context = canvas.getContext('2d');
  context.drawImage(video, 0, 0, width, height);
  canvas.toBlob(upload);
};

var upload = function(image){
  var title = prompt('Add a title for your recording', 'A very creative title!');
  recorder.getWAV().then(function(wav){
    var upload = SC.upload({
      title: title,
      sharing: 'private',
      asset_data: wav,
      artwork_data: image
    });
    upload.then(showTrack);
    upload.request.addEventListener('progress', function(event){
      message.innerHTML = 'Uploading (' + (event.loaded / event.total) * 100 + '%)';
    });
  });
  overlay.style.zIndex = 0;
  message.innerHTML = 'Uploading...';
};

var showTrack = function(track){
  message.innerHTML = '<p>Your track has been successfully uploaded!</p>';
  message.innerHTML += '<a href="' + track.permalink_url + '" target="_blank">Check it out on SoundCloud</a>';
};

// connect flow
var connectButton = document.getElementById('connect');
connectButton.addEventListener('click', function(){
  // connect to SoundCloud and disable the button
  SC.connect().then(function(){
    message.innerHTML = '';
    overlay.style.zIndex = -2;
  });
});
