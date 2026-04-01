import SC from "soundcloud";

/**
 * SC.Recorder
 */

const rc: SC.Recorder = new SC.Recorder({
    source: 'yayayaya',
    context: new AudioContext(),
});

/**
* API
*/

const scOpt = {
    oauth_token: 'yayayaya',
    client_id: 'yayayaya',
    redirect_uri: 'yayayaya',
    baseURL: 'yayayaya',
    connectURL: 'yayayaya',
};

SC.initialize(scOpt);

console.log('SC.isConnected() => ', SC.isConnected())

SC.connect({
    client_id: 'dudul',
    redirect_uri: 'http://google.com',
})
    .then(() => {
        try {
            return SC.get('http://souncloud.com', scOpt);
        } catch (error) {
            console.error(error);
            return Promise.resolve();
        }
    })
    .then(() => {
        try {
            return SC.post('http://souncloud.com', scOpt);
        } catch (error) {
            console.error(error);
            return Promise.resolve();
        }
    })
    .then(() => {
        try {
            return SC.put('http://souncloud.com', scOpt);
        } catch (error) {
            console.error(error);
            return Promise.resolve();
        }
    })
    .then(() => {
        try {
            return SC.delete('http://souncloud.com', scOpt);
        } catch (error) {
            console.error(error);
            return Promise.resolve();
        }
    })
    .then(() => {
        try {
            return SC.resolve('http://souncloud.com');
        } catch (error) {
            console.error(error);
            return Promise.resolve();
        }
    }).then(() => {
        try {
            return SC.oEmbed('http://souncloud.com', {
                element: 'element',
                scope: 'read',
                url: 'http://souncloud.com'
            });
        } catch (error) {
            console.error(error);
            return Promise.resolve({});
        }
    }).then(() => {
        try {
            return SC.oEmbed('http://souncloud.com', {
                element: 'element',
                scope: 'read',
                url: 'http://souncloud.com'
            });
        } catch (error) {
            console.error(error);
            return Promise.resolve({});
        }
    }).then(() => {
        try {
            return SC.stream('abcdefg', 'token');
        } catch (error) {
            console.error(error);
            return Promise.resolve({});
        }
    }).then(() => {
        try {
            return SC.upload({
                title: 'Upload title',
                asset_data: 'data',
                file: 'SomeFile.mp3',
                progress: (p) => console.log('Progress: ' + p),
            });
        } catch (error) {
            console.error(error);
            return Promise.resolve();
        }
    });




