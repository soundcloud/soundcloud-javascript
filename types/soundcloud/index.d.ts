// Type definitions for soundcloud 3.3.2
// Project: https://github.com/soundcloud/soundcloud-javascript
// Definitions by: alrickemilien <https://github.com/soundcloud>

/// <reference lib="dom"/>

export default SC;

declare namespace SC {
    interface RecorderOptions {
        source: string;
        context?: AudioContext;
    }

    export class Recorder {
        constructor(options: RecorderOptions);
        delete(): void;
        getBuffer(): Promise<AudioBuffer>;
        getWAV(): Promise<Blob>;
        play(): Promise<AudioBufferSourceNode>;
        saveAs(filename: string): Promise<void>;
        start(): Promise<AudioNode>;
        stop(): void;
    }

    /**
     * SCAudio.Player functions
     */
    export interface SCPlayer {
        play: (...args: any[]) => any;
        pause: (...args: any[]) => any;
        seek: (...args: any[]) => any;
        getVolume: (...args: any[]) => any;
        setVolume: (...args: any[]) => any;
        currentTime: (...args: any[]) => any;
        getDuration: (...args: any[]) => any;
        isBuffering: () => boolean;
        isPlaying: () => boolean;
        isActuallyPlaying: () => boolean;
        isEnded: () => boolean;
        isDead: () => boolean;
        kill: (...args: any[]) => any;
        hasErrored: () => boolean;
        getState: () => "playing" | "ended" | "paused" | "dead" | "loading";
    }

    interface DialogOptions {
        client_id: string,
        redirect_uri: string,
        response_type: string,
        scope: string,
        display: string,
    }

    interface SCOptions {
        oauth_token?: string;
        client_id?: string;
        redirect_uri?: string;
        baseURL?: string;
        connectURL?: string;
    }

    export function connect(options?: {
        client_id?: string,
        redirect_uri?: string
    }): Promise<DialogOptions>;
    export function connectCallback(): void;
    export function get(path: string, params: FormData | any): Promise<any>;
    export function initialize(options: SCOptions): void;
    export function isConnected(): boolean;

    export function oEmbed(url: string, options?: {
        element?: string,
        scope?: string,
        url?: string
    }): Promise<DialogOptions>;

    export function post(path: string, params: FormData | any): Promise<any>;
    export function put(path: string, params: FormData | any): Promise<any>;

    // delete is a keyword in typescript leading to this trick
    function _delete(path: string, params: FormData | any): Promise<any>;
    export { _delete as delete };

    export function resolve(url: string): Promise<any>;
    export function stream(trackPath: string, secretToken: string): Promise<SCPlayer>;
    export function upload(options: {
        title: string,
        asset_data?: string,
        file?: string,
        progress?: (...args: any[]) => any,
    }): Promise<any>;
}

