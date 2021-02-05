---
layout: post
title: "Handling backpressure in Node.js streams"
---

Here comes the sequel to [my introduction to Node.js streams]({{ site.baseurl }}{% link _posts/2020-04-16-Node_Streams_For_Fun_And_Profit.md %}).


## Quick recap

The first blog posts focused on the basics of Node.js streams and error handling.

![Node.js stream family](/assets/img/node_streams.svg "Node.js stream family diagram")

Stream pipelines start from a source (`Readable`), go through 0 to n intermediates (`Duplex` with 1 `Writable` and 1 `Readable` side)
and end with a destination (`Writable`):

```javascript
const { pipeline, Readable, Transform, Writable } = require("stream");

const myReadableStream /* = instantiate Readable stream */;
const myTransformStream1  /* = instantiate Transform stream */;
const myTransformStream2  /* = instantiate Transform stream */;
const myTransformStream3  /* = instantiate Transform stream */;
const myWritableStream /* = instantiate Writable stream */;

pipeline(
    myReadableStream,
    myTransformStream1,
    myTransformStream2,
    myTransformStream3,
    myWritableStream,
    (err) => { /* ... */ }
);
```

[`pipeline`](https://nodejs.org/api/stream.html#stream_stream_pipeline_source_transforms_destination_callback)
is favoured over [`pipe`](https://nodejs.org/api/stream.html#stream_readable_pipe_destination_options) as it allows for a single completion listener.
This listener is invoked when an error occurs, regardless of the `autoDestroy` setting of any of the streams.

We then went on and implemented the `map` operation:

```javascript
const { Transform } = require("stream");

class MapTransform extends Transform {
    
    constructor(mapFunction) {
        super({ objectMode: true });
        this.mapFunction = mapFunction;
    }

    _transform(chunk, encoding, callback) {
        callback(null, this.mapFunction(chunk));
    }
}
```

and the `zip` operation:

```javascript
const { Readable } = require("stream");

class ZipReadable extends Readable {

    constructor(...upstreams) { // (1)
        super({ objectMode : true });
        this.initialized = false;
        this.waitingForData = false;
        this.endedUpstreamCount = 0;
        this.streams = upstreams;
        this.chunks = upstreams.map(() => []); // (2)
    }

    _read(size) {
        if (!this.initialized) {
            this._startReading();
            this.initialized = true;
        }
        const bound = Math.min(size, ...this.chunks.map(array => array.length));  // (3)
        if (bound === 0) {
            this.waitingForData = true;
            return;
        }
        this.waitingForData = false;
        this.chunks
            .map(a => a.splice(0, bound))
            .reduce((prev, curr) => {  // (4)
                const result = [];
                for (let i = 0; i < bound; i++) {
                    const previous = (Array.isArray(prev[i])) ? prev[i] : [prev[i]];
                    result.push([...previous, curr[i]]);
                }
                return result
            })
            .forEach((pair) => {
                this.push(pair);
            })
    }

    _startReading() {
        this.streams.forEach((stream, index) => {
            stream.on('end', () => {
                this.endedUpstreamCount++;
                if (this.endedUpstreamCount === this.streams.length) { // (5)
                    this.push(null);
                }
            });
            stream.on('data', (chunk) => {
                const streamChunks = this.chunks[index];
                streamChunks.push(chunk);
                if (this.waitingForData) {
                    this._read(streamChunks.length);
                }
            });
        });
    }
}
```

However, we left a very important aspect out of the discussion: do these implementations
properly handle backpressure?


## Back to backpressure

A pipeline is made of at least two streams: a source (`Readable`) and a destination (`Writable`).
Backpressure happens when the source emits chunks of data faster than the destination can process them.

The following image exemplifies a backpressure problem with servers, but the same idea applies to streams.
After all, one could consider servers as streams reading requests and emitting responses. 


![Backpressure illustrated](/assets/img/backpressure.gif "backpressure in action")

In the illustration, server A sends requests to B which sends requests to C.
C can only process 75 requests per second (rps), while B processes 100 rps.

Depending on the context, one of the following strategies can be applied:

 1. let B drop requests (which can be acceptable for non-critical services)
 1. boost server C: optimise the configuration and hardware of server C so that its rps aligns with B's (acceptable if you have some budget)
 1. keep unprocessed requests in a buffer until server C catches up (acceptable for temporary issues)
 1. tell server B (and A) to slow down, A's clients will be asked to wait/retry later

If option 1 or 2 is applicable, then you will not need to read the rest of this article 😁

### Buffering in streams

### Overwhelm notifications

### Back to `map` and `zip`
