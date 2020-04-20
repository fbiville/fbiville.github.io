---
layout: post
title: "Node.js Streams For Fun And Profit"
---

I joined the [riff](https://projectriff.io) team at Pivotal a year and a half ago.
I have been working for more than a year on [riff](https://projectriff.io) invokers.
 
This probably deserves a blog post on its own, but invokers, in short, have the responsibility of invoking user-defined functions
and exposing a way to send inputs and receive outputs.
The [riff invocation protocol](https://github.com/projectriff/invoker-specification/) formally defines the scope of such invokers.

Part of my job has been to update the existing invokers (especially the [Node.js one](https://github.com/projectriff/node-function-invoker)) so that they comply with this spec.
As the invocation protocol is a [streaming-first protocol](https://github.com/projectriff/invoker-specification/blob/a41d885fb411dc00e7ea3f7724ede4c435121a62/riff-rpc.proto#L13),
I had to really brush up my knowledge about Node.js streams (narrator's voice: well, learn from zero).

I learnt a lot by trial and error, probably more than I care to admit.
This blog post serves as an introduction to Node.js streams.
Hopefully, it also outlines some good practices, and some annoying pitfalls to avoid.

## Thanks, Dear (Proof)Readers

I would like to thank:

 - [Alvaro Videla](https://twitter.com/old_sound)
 - [Nicolas Kosinski](https://twitter.com/nicokosi)
 - [Vladimir de Turckheim](https://twitter.com/poledesfetes)

for the various suggestions to make this better. Thanks ❤️

## Harder, Better, Mapper, Zipper

Let's create a tiny Node.js library that works with streams and provide
familiar functional operators such as `map` and `zip`.

First, what is a stream?

Loosely defined, a stream conveys (possibly indefinitely) chunks of data, to which specific operations can be applied.

How does that translate to Node.js exactly?

## Streams in Node.js

Node.js streams come in two flavors: [`Readable`](https://nodejs.org/api/stream.html#stream_readable_streams) and [`Writable`](https://nodejs.org/api/stream.html#stream_writable_streams).

 - `Readable` streams can be read from
 - `Writable` streams can be written to
 
[`Readable#pipe`](https://nodejs.org/api/stream.html#stream_readable_pipe_destination_options) allows to create a pipeline, where the inputs come from the `Readable` stream and are written
to the destination `Writable` stream.

```javascript
const { Readable, Writable } = require("stream");

const myReadableStream /* = instantiate Readable stream */;
const myWritableStream /* = instantiate Writable stream */;

myReadableStream.pipe(myWritableStream);
```

What happens here is that the source `Readable` stream goes from a paused state to a [flowing state](https://nodejs.org/api/stream.html#stream_three_states) after `pipe` is called.

> You can manually manage such state transitions with functions like [`Readable#pause`](https://nodejs.org/api/stream.html#stream_readable_pause)
or [`Readable#resume`](https://nodejs.org/api/stream.html#stream_readable_resume) but we are only going to rely on automatic flowing mode from now on.

A Node.js stream can also encapsulate a `Readable` side **and** a `Writable` side, such streams are called [`Duplex`](https://nodejs.org/api/stream.html#stream_class_stream_duplex) streams.
If outputs of the duplex stream depend on inputs, then a [`Transform`](https://nodejs.org/api/stream.html#stream_class_stream_transform) stream is the way to go (it is a specialization of the `Duplex` type).

> Outputs are _read_, hence they come from the `Readable` side of the `Duplex` stream.
>
> Inputs are _written_, hence they go to the `Writable` side of the `Duplex` stream.
>
> `Transform` streams automatically expose chunks from the `Writable` side to a user-defined transformation function.
> The function results are automatically forwarded to the `Readable` side of the `Transform` stream.
>
> Note: unfortunately, `Duplex` streams do not differentiate `Readable` errors from `Writable` ones.

![Node.js stream family](/assets/img/node_streams.svg "Node.js stream family diagram")

These compound streams are interesting for any kind of pipeline beyond basic ones.
They encode intermediate transformations before chunks reach the final destination `Writable` stream.

```javascript
const { Readable, Transform, Writable } = require("stream");

const myReadableStream /* = instantiate Readable stream */;
const myTransformStream1  /* = instantiate Transform stream */;
const myTransformStream2  /* = instantiate Transform stream */;
const myTransformStream3  /* = instantiate Transform stream */;
const myWritableStream /* = instantiate Writable stream */;

myReadableStream
    .pipe(myTransformStream1)
    .pipe(myTransformStream2)
    .pipe(myTransformStream3)
    .pipe(myWritableStream);
```

The above "fluent" example works because `Readable#pipe` returns the reference to the destination stream.
`Transform` (or more generally, `Duplex`) streams have two sides, so they can be piped to (`Writable` side) and then from (`Readable` side) via a new `pipe` call.

However, this is not necessarily the best way to define a **linear** pipeline though.
One important limitation is that `pipe` does **not** propagate errors from an upstream stream to the next downstream one.

> Emphasis on linear here. Streams can be piped from and to several times, so you can end up with graph-shaped pipelines.

A more robust alternative in case of linear pipelines is to use the built-in `pipeline` function.
It automatically forwards errors and must be called with:

 - 1 `Readable` stream (a.k.a. the source)
 - 0..n `Duplex` stream (a.k.a. intermediates)
 - 1 `Writable` stream (a.k.a. the destination)
 
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

You can also provide a callback that will be invoked when the pipeline completes, abnormally (i.e. when an error occurs) or not.

> `pipeline` actually supports more than streams but that's out of scope for this article.
> Feel free to check [the documentation](https://nodejs.org/api/stream.html#stream_stream_pipeline_source_transforms_destination_callback) to learn about other usages.

Now that the general pipeline model is understood, let's dive into the details of how `map` works, learning how custom streams are implemented in the process.

## You Can't `map` This

Credit where credit is due, I am going to reuse the awesome diagrams of [project Reactor](https://projectreactor.io/).

![`map` diagram](/assets/img/mapForFlux.svg "`map` diagram")

The top of the diagram depicts chunks as they initially come to the stream, as well as
the stream completion signal (marked by the bold vertical line at the end of the sequence).

The `map` operation here is in the middle, applying a transformation from circles to squares.

The bottom part of the diagram shows the resulting chunks and how the completion signal is propagated as-is.

In other terms, `map` applies a transformation function to each element of the stream, in the order they arrive.

Let's start with a [Jasmine](https://jasmine.github.io/) test:

```javascript

const { PassThrough, pipeline, Readable } = require("stream");

describe("map operator =>", () => {
 
    it("applies transformations to chunks", (done) => {
        const source = Readable.from([1, 2, 3], { objectMode: true }); // (1)
        const transformation = new MapTransform((number) => number ** 2); // (2)
        const destination = new PassThrough({ objectMode: true }); // (3)
        const result = [];

        // ??? (4)

        pipeline(
            source,
            transformation,
            destination,
            (err) => { // (5)
                expect(err).toBeFalsy('pipeline should successfully complete');
                expect(result).toEqual([1, 4, 9]);
                done();
            }
        );
    });
})
```

A few things of note:

1. You can create a `Readable` from an iterable source such as an array, or a [generator function](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/function*). Here, the stream will emit each array element in succession.
The [`objectMode`](https://nodejs.org/api/stream.html#stream_object_mode) option configures the stream to receive any kind of chunk.
The default chunk data type is textual or binary (i.e. strings, `Buffer` or `Uint8Array`).
Quite surprisingly, the default mode when specifically using `Readable#from` is the object mode, contrary to stream constructors. However redundant, the object mode is set here just for consistency's sake.
2. `MapTransform` does not exist yet, we will have to figure out its implementation next but we can assume its constructor accepts a transformation function (here: the square function).
We could pass the `objectMode` setting, but let's assume it always operates this way.
3. [`PassThrough`](https://nodejs.org/api/stream.html#stream_class_stream_passthrough) is a special implementation of `Transform` stream which directly forwards inputs as outputs (it applies the identity function in other words).
4. we need to somehow accumulate the observed outputs to `result`, more on that soon
5. we leverage the completion callback of `pipeline` to verify a few things:
    1. the pipeline completes successfully
    2. the observed results are consistent with the transformation we intend to apply on the initial chunks
    3. `done` is a Jasmine utility to notify the test runner of the (asynchronous) test completion
    
For people familiar with the given-when-then test structure, this test may look a bit strange.
Indeed, the order is changed here to given-then-when. This has to do with the asynchronous nature of streams.
We have to set up the expectations (the "then" block) before data starts flowing in, i.e. before `pipeline` is called.
    
How can we be sure the test completes? After all, streams can be infinite.
In that case, `Readable#from` reads a finite array and will send a completion signal once the array is fully consumed.
This completion signal will be forwarded to all the other (downstream) streams, we can therefore be confident the `pipeline` completion callback is going to be called.
In the worst case, the test will hang for a while until the Jasmine timeout is reached, causing a test failure.

We now need to figure out how to complete the test.

Node.js streams extend [`EventEmitter`](https://nodejs.org/api/events.html#events_events).
They emit specific events that can be listened to via functions such as `EventEmitter#on(eventType, callback)`.
Event listeners are **synchronously** executed in the order they are added (you can tweak the order via alternative functions such as `EventEmitter#prependListener(eventType, callback)`).

Our test needs to observe chunks written to the destination stream.
Technically, the destination could just be a `Writable` stream as this is the only requirement of `pipe` and `pipeline`.
However, we need to read the chunks that have been written to, so using a `Transform` stream such as `PassThrough` definitely helps as it exposes a `Readable` side.

In particular, `Readable` streams emit a [`data` event](https://nodejs.org/api/stream.html#stream_event_data) with the associated chunk of data. That is exactly what we need to
accumulate the results!

Our test now becomes:

```javascript
const { PassThrough, pipeline, Readable } = require("stream");

describe("map operator =>", () => {
 
    it("applies transformations to chunks", (done) => {
        const source = Readable.from([1, 2, 3], { objectMode: true });
        const transformation = new MapTransform((number) => number ** 2);
        const destination = new PassThrough({ objectMode: true });
        const result = [];

        destination.on('data', (chunk) => {
            result.push(chunk);
        });

        pipeline(
            source,
            transformation,
            destination,
            (err) => {
                expect(err).toBeFalsy('pipeline should successfully complete');
                expect(result).toEqual([1, 4, 9]);
                done();
            }
        );
    });
})
```

The test seems ready. If I execute it, I get:
```shell
 $ npm test
Failures:
1) map operator => applies transformations to chunks
  Message:
    ReferenceError: MapTransform is not defined
```

Just to make sure the pipeline is properly set up, let's temporarily replace `MapTransform` with `PassThrough` in object mode.
In that case, the test should fail because `result` will be equal to `[1, 2, 3]` and not `[1, 4, 9]`.
Let's see:
```shell
 $ npm test
1) map operator => applies transformations to chunks
  Message:
    Expected $[1] = 2 to equal 4.
    Expected $[2] = 3 to equal 9.
```

The test fails as expected, let's focus on the implementation now.

`map` is an intermediate transformation, directly correlating outputs to inputs.
Hence, `Transform` is the ideal choice.

Let's subclass `Transform`, then:

```javascript
const { Transform } = require("stream");

class MapTransform extends Transform {
    
    constructor(mapFunction) {
        super({ objectMode: true });
        this.mapFunction = mapFunction;
    }

    // ???
}
```

`Transform` streams need to implement the [`_transform` method](https://nodejs.org/api/stream.html#stream_transform_transform_chunk_encoding_callback).
The first parameter is the chunk of data coming to the `Writable` side, the second is the encoding (which is irrelevant in object mode) and the third one is a callback
that must be called **exactly once** to notify either an error or null (first argument) or pass on the result to the `Readable` side (second argument).

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

Let's see if the test passes now:

```shell
 $ npm test

> jasmine

Randomized with seed 30817
Started
.


1 spec, 0 failures
Finished in 0.014 seconds
```

🍾 It does!

We could improve a few things, such as accepting asynchronous functions and handling throwing functions.
This is left as an exercise to the readers 😉 (hint: `Promise.resolve` bridges synchronous and asynchronous functions)


## Zip it!

`zip` is slightly more complex than `map` as it operates on (at least) two streams.
Let's see it in action (thanks again to [project Reactor](https://projectreactor.io/) for the diagrams):

![`zip` diagram](/assets/img/zip.svg "`zip` diagram")

`zip` pairs up chunks by order of arrival.
Once the pair is formed, a transformation function is applied to it.
`zip` completes when the last stream completes.

For simplicity's sake, our `zip` implementation will only pair elements together but not apply any transformation.

Time to express our intent with a test:

```javascript
const { PassThrough, pipeline, Readable } = require("stream");

describe("zip operator =>", () => {

    it("pairs chunks from upstream streams", (done) => {
        const upstream1 = Readable.from([1, 2, 3], { objectMode: true }); // (1)
        const upstream2 = Readable.from(["Un", "Deux", "Trois"], { objectMode: true }); // (1)
        const zipSource = new ZipReadable(upstream1, upstream2); // (2)
        const destination = new PassThrough({ objectMode: true }); // (3)
        const result = []; // (4)

        destination.on('data', (chunk) => { // (4)
            result.push(chunk);
        });

        pipeline(
            zipSource,
            destination,
            (err) => { // (5)
                expect(err).toBeFalsy('pipeline should successfully complete');
                expect(result).toEqual([
                    [1, "Un"],
                    [2, "Deux"],
                    [3, "Trois"]
                ]);
                done();
            }
        );
    })
})

```

This is very similar to the previous `map` test:

1. we need two streams to read from, hence the creation of two `Readable` streams from different arrays.
Note we could (and should for a production implementation) spice up the test a bit by introducing latency, thus making sure we properly wait for chunks to be paired in order.
This could be done with [generator functions](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/function*)
and [`setTimeout`](https://developer.mozilla.org/en-US/docs/Web/API/WindowOrWorkerGlobalScope/setTimeout).
1. the next step will be to figure out how to implement `ZipReadable`. We can safely assume it accepts two `Readable` streams to read chunks from.
1. same as before, we rely on `PassThrough` to receive the resulting chunks. We will use its `Readable` side to observe and accumulate the results.
1. we accumulate the observed resulting chunks in `result`, based on the [`data` event](https://nodejs.org/api/stream.html#stream_event_data) emitted by the `Readable` side of the `PassThrough` stream
1. finally, we rely on the completion callback to make sure, as before, that the pipeline successfully completes, the resulting chunks are as we expect and notify Jasmine of the test completion

Let's run the test:
```shell
 $ npm test
Failures:
1) zip operator => pairs chunks from upstream streams
  Message:
    ReferenceError: ZipReadable is not defined
```


Let's create an implementation that works with two streams for now.
First, what kind of stream our `ZipReadable` should be? Let's go with `Readable`, as `ZipReadable` acts as a source
built upon two upstream streams.

```javascript
const { Readable } = require("stream");

class ZipReadable extends Readable {
    
    constructor(stream1, stream2) {
        super({ objectMode : true });
        this.stream1 = stream1;
        this.stream2 = stream2;
    }
    
    // ??? (2)

    _startReading() {
        this.stream1.on('data', (chunk1) => {
            // ??? (1)
        });
        this.stream2.on('data', (chunk2) => {
            // ??? (1)
        });
    }
}
```

 1. we need to get data from both the upstream streams. We chose here not to call `_startReading` in the constructor.
The goal is to start reading only when a first consumer wants to read data. 
 1. we somehow need to emit data whenever `ZipReadable` is read from
 
Let's first worry about buffering the incoming data:

```javascript
const { Readable } = require("stream");

class ZipReadable extends Readable {

    constructor(stream1, stream2) {
        super({ objectMode : true });
        this.chunks1 = [];
        this.chunks2 = [];
        this.stream1 = stream1;
        this.stream2 = stream2;
    }

    // ???

    _startReading() {
        this.stream1.on('data', (chunk1) => {
            this.chunks1.push(chunk1);
        });
        this.stream2.on('data', (chunk2) => {
            this.chunks2.push(chunk2);
        });
    }

}
```

Nothing too fancy here, chunks are pushed to the corresponding array.
Custom `Readable` need to implement [`Readable#_read`](https://nodejs.org/api/stream.html#stream_readable_read_size_1).
Results are pushed to consumers via [`Readable#push`](https://nodejs.org/api/stream.html#stream_readable_push_chunk_encoding).

Let's have a crack at it:
```javascript
const { Readable } = require("stream");

class ZipReadable extends Readable {

    constructor(stream1, stream2) {
        super({ objectMode : true });
        this.initialized = false;
        this.stream1 = stream1;
        this.stream2 = stream2;
        this.chunks1 = [];
        this.chunks2 = [];
    }

    _read(size) {
        if (!this.initialized) {
            this._startReading(); // (1)
            this.initialized = true;
        }
        const bound = Math.min(size, this.chunks1.length, this.chunks2.length); // (2)
        if (bound === 0) {
            return;
        }
        const readyChunks1 = this.chunks1.splice(0, bound); // (3)
        const readyChunks2 = this.chunks2.splice(0, bound); // (3)
        for (let i = 0; i < bound; i++) {
            const pair = [readyChunks1[i], readyChunks2[i]]; // (4)
            this.push(pair); // (5)
        }
    }

    _startReading() {
        this.stream1.on('data', (chunk1) => {
            this.chunks1.push(chunk1);
        });
        this.stream2.on('data', (chunk2) => {
            this.chunks2.push(chunk2);
        });
    }
}
```

1. upon the first call to `Readable#_read` (when `pipeline` is called in the test), we start reading data from the upstream sources.
As we do not want to subscribe to the `'data'` event multiple times, we guard this initialization with the `this.initialized` flag.
1. `size` is advisory, so we could just ignore it but it does not cost much to include in the bound computation. More on that towards the end of this article.
1. `splice` is used here to remove and return the `bound` first elements of each array as well as shift the remaining ones. That way, we do not keep consumed chunks around.
1. the core logic of `zip` is here, we create a pair (an array) of chunks accumulated from two streams
1. finally, we publish that pair

Let's see if our test is happy:

```shell
Failures:
1) zip operator => pairs chunks from upstream streams
  Message:
    Error: Timeout - Async function did not complete within 5000ms (set by jasmine.DEFAULT_TIMEOUT_INTERVAL)
```

Oh no! The test fails.
Looking at the above implementation, this actually makes sense.
When `_read` is called the first time, there is no guarantee at all that data has been buffered yet from the upstream sources.

Looking a bit more closely to [`Readable#_read` documentation](https://nodejs.org/api/stream.html#stream_readable_read_size_1), we can read:

> Once the readable._read() method has been called, it will not be called again until more data is pushed through the readable.push() method.

Ahah! That's exactly the issue we hit! `_read` is called a first time when the pipeline is set up, but no data has come yet so nothing to push.
Then, we are stuck forever as no further `Readable#push` calls can occur because `_read` will not be called anymore.

Lucky for us, nothing prevents `Readable#push`, or even `Readable#_read` from being called from elsewhere in the `Readable` implementation.

Let's try again (and add a few temporary logs while we're at it):
```javascript
const { Readable } = require("stream");

class ZipReadable extends Readable {

    constructor(stream1, stream2) {
        super({ objectMode : true });
        this.initialized = false;
        this.waitingForData = false;
        this.stream1 = stream1;
        this.stream2 = stream2;
        this.chunks1 = [];
        this.chunks2 = [];
    }

    _read(size) {
        if (!this.initialized) {
            console.log('Initializing pipeline');
            this._startReading();
            this.initialized = true;
        }
        const bound = Math.min(size, this.chunks1.length, this.chunks2.length);
        if (bound === 0) {
            console.log(`Waiting for data, nothing to do for now...`);
            this.waitingForData = true;
            return;
        }
        console.log(`Data flowing: ${bound} element(s) from each source to zip!`);
        this.waitingForData = false;
        const readyChunks1 = this.chunks1.splice(0, bound);
        const readyChunks2 = this.chunks2.splice(0, bound);
        for (let i = 0; i < bound; i++) {
            const pair = [readyChunks1[i], readyChunks2[i]];
            this.push(pair);
        }
    }

    _startReading() {
        this.stream1.on('data', (chunk1) => {
            console.log(`Chunk 1 received: ${chunk1}`);
            this.chunks1.push(chunk1);
            if (this.waitingForData) {
                console.log(`Waiting for data, calling with ${this.chunks1.length} element(s) from first upstream`);
                this._read(this.chunks1.length);
            }
        });
        this.stream2.on('data', (chunk2) => {
            console.log(`Chunk 2 received: ${chunk2}`);
            this.chunks2.push(chunk2);
            if (this.waitingForData) {
                console.log(`Waiting for data, calling with ${this.chunks2.length} element(s) from second upstream`);
                this._read(this.chunks2.length);
            }
        });
    }
}
```

Let's re-run the test:

```shell
 $ npm test
Initializing pipeline
Waiting for data, nothing to do for now...
Chunk 1 received: 1
Waiting for data, calling with 1 element(s) from first upstream
Waiting for data, nothing to do for now...
Chunk 2 received: Un
Waiting for data, calling with 1 element(s) from second upstream
Data flowing: 1 element(s) from each source to zip!
Chunk 1 received: 2
Chunk 2 received: Deux
Chunk 1 received: 3
Chunk 2 received: Trois
Data flowing: 2 element(s) from each source to zip!
Waiting for data, nothing to do for now...

Failures:
1) zip operator => pairs chunks from upstream streams
  Message:
    Error: Timeout - Async function did not complete within 5000ms (set by jasmine.DEFAULT_TIMEOUT_INTERVAL)
```

Hmm, the test still fails, but the implementation seems to behave correctly.
What actually happens is that our `ZipReadable` implementation never completes.
Looking again at the [`Readable#push`](https://nodejs.org/api/stream.html#stream_readable_push_chunk_encoding) documentation,
we can see pushing that `null` notifies downstream consumers that the stream is done emitting data.

Now, when should we do that?
If we look at the Reactor diagram of `zip` again:

![`zip` diagram](/assets/img/zip.svg "`zip` diagram")

... we can see that the completion should be sent when the last stream completes.
`Readable` streams notify consumers with the [`end` event](https://nodejs.org/api/stream.html#stream_event_end) when they are done.
Now that we have got everything figured out, let's get rid of the logs and fix our implementation:

```javascript
// DO NOT USE IN PRODUCTION - SEE BELOW FOR DETAILS
const { Readable } = require("stream");

class ZipReadable extends Readable {

    constructor(stream1, stream2) {
        super({ objectMode : true });
        this.initialized = false;
        this.waitingForData = false;
        this.endedUpstreamCount = 0; // (1)
        this.stream1 = stream1;
        this.stream2 = stream2;
        this.chunks1 = [];
        this.chunks2 = [];
    }

    _read(size) {
        if (!this.initialized) {
            this._startReading();
            this.initialized = true;
        }
        const bound = Math.min(size, this.chunks1.length, this.chunks2.length);
        if (bound === 0) {
            this.waitingForData = true;
            return;
        }
        this.waitingForData = false;
        const readyChunks1 = this.chunks1.splice(0, bound);
        const readyChunks2 = this.chunks2.splice(0, bound);
        for (let i = 0; i < bound; i++) {
            const pair = [readyChunks1[i], readyChunks2[i]];
            this.push(pair);
        }
    }

    _startReading() {
        this.stream1.on('end', () => { // (2)
            this.endedUpstreamCount++;
            if (this.endedUpstreamCount === 2) { // (3)
                this.push(null);
            }
        });
        this.stream2.on('end', () => { // (2)
            this.endedUpstreamCount++;
            if (this.endedUpstreamCount === 2) { // (3)
                this.push(null);
            }
        });
        this.stream1.on('data', (chunk1) => {
            this.chunks1.push(chunk1);
            if (this.waitingForData) {
                this._read(this.chunks1.length);
            }
        });
        this.stream2.on('data', (chunk2) => {
            this.chunks2.push(chunk2);
            if (this.waitingForData) {
                this._read(this.chunks2.length);
            }
        });
    }
}
```

1. we introduce a counter to keep track of upstream stream completion.
1. we observe each upstream stream completion and increment the counter when than occurs.
1. we notify the `zip` stream completion when all upstream streams are done.

Let's run the tests:

```shell
 $ npm test

2 specs, 0 failures
```

Yay, it passes 🥳

However, the implementation could definitely be refactored as there is a lot of duplicated behaviors.
It could even be generalized to _n_ upstream sources (the corresponding test is very similar to the one with 2 sources)!

And here we go:

```javascript
// DO NOT USE IN PRODUCTION - SEE BELOW FOR DETAILS
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

1. we use now the ["rest parameter" syntax](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters) to accept any number of streams.
We could arguably improve the signature further by having two mandatory streams and an optional rest ones for extra streams.
1. we just have to create an initial empty array of chunks for every stream
1. we compute the current length of each chunk array and use the ["spread syntax"](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_syntax) to fit these lengths into separate arguments of `Math.min`.
1. finally, after `Array#splice` extract the `bound` first parameter of each chunk array, these arrays are reduced into pairs and then published via `Readable#push`
1. the counter now need to reflect the dynamic number of upstream sources instead of the hardcoded 2 of the previous version

Does the existing test still pass?

```shell
 $ npm test

2 specs, 0 failures
```
Yes!

## One More Thing

There is one (albeit very important) aspect of streams I deliberately did not mention here: [backpressure](https://nodejs.org/es/docs/guides/backpressuring-in-streams/).
Backpressure happens when downstream streams cannot keep up with upstream streams. Basically, the latter conveys data too fast for the first.

The good news is that `Readable#pipe` handles backpressure "for free" (and I assume `pipeline` as well).

That being said, do our custom implementations of `zip` and `map` [handle backpressure correctly](https://nodejs.org/en/docs/guides/backpressuring-in-streams/#rules-to-abide-by-when-implementing-custom-streams)?

Spoiler alert: I'm afraid not.

However, there will be a dedicated blog post about this, with updates to the initial implementations 😉

## Going further

If you notice improvements (other than backpressure-related ones), please send a [Pull Request](https://github.com/fbiville/fbiville.github.io) and/or reach out to me on [Twitter](https://twitter.com/fbiville).
Here are a few references that helped me in my stream learning journey that are worth sharing:

 - [https://nodejs.org/api/stream.html](https://nodejs.org/api/stream.html): the official documentation of Node.js streams, including implementation guides
 - [https://github.com/nodejs/help/](https://github.com/nodejs/help/): stuck with something? Open an issue in this repository and Node.js maintainers will help you!
 - [https://www.w3.org/TR/streams-api/](https://www.w3.org/TR/streams-api/) W3C/WhatWG stream spec (it slightly differs from Node.js stream API, but many concepts overlap)
 - [https://v8.dev/blog](https://v8.dev/blog): not directly related to streams, but this blog authored by v8 maintainers is a goldmine of information w.r.t. how v8 works and new Javascript features
