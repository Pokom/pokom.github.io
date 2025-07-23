+++
date = '2025-07-23'
draft = false
title = 'gRPC'
+++

I've heard of gRPC for quite some time, ran many applications in my life as a platform engineer that had gRPC endpoints, but never directly contributed to it.
gRPC is coming up more frequently now that I'm working as a backend engineer, and I feel like I need to dive deeper into the fundamentals.
The code is intuitive enough to update existing handlers.
But what happens if you need to create a new handler?
Or if you need to update how [the client is initialized](github.com/grafana/synthetic-monitoring-agent/issues/738)?

## What is gRPC?

Taken directly from their [website](grpc.io):
> A high performance, open source universal RPC framework


Okay, that does not help me in the slightest.
Wikipedia helped me a bit more with defining [RPC](https://en.wikipedia.org/wiki/Remote_procedure_call), which stands for a remote procedure call:
> In distributed computing, a remote procedure call (RPC) is when a computer program causes a procedure (subroutine) to execute in a different address space (commonly on another computer on a shared computer network), which is written as if it were a normal (local) procedure call, without the programmer explicitly writing the details for the remote interaction.

This is still abstract to me, but it at least gets me a bit closer.
Given the context of how I've seen gRPC used out in the wild, I interpret this as a way of executing code remotely without having the be aware of the network boundaries.
Why is this preferring over HTTP is not yet clear, but let's follow along.

So okay, gRPC is Google's high performance, open source, universal RPC framework.
Great, now how do I start using it?

### Getting started

I won't rewrite their [quickstart guide](https://grpc.io/docs/languages/go/quickstart/), but one thing that's interesting is the need to install a protocol buffer compiler.
This immediately clues in that there's a tight coupling between gRPC and Protocol Buffers, but we'll come to that later.
After cloning the repo, you end up with the following tree:

```
 ~/dev/poko/grpc-go/examples/helloworld/ v1.74.2 tree
.
├── greeter_client
│   └── main.go
├── greeter_server
│   └── main.go
├── helloworld
│   ├── helloworld_grpc.pb.go
│   ├── helloworld.pb.go
│   └── helloworld.proto
└── README.md
```

At face value, the client and server look nearly identitical to what you would expect in any other network based application.
You have a server that is listening on a specific address and port waiting for connections.
The client is initialized to point towards the host and port the server is going to run on.
But there's _one_ key bit that is different from a typical http application:

```go
c := pb.NewGreeterClient(conn)
```

This is the bit that is very different.
When looking at the code for `pb.NewGreaterClient`, this looks to be automatically generated:

```go
// GreeterClient is the client API for Greeter service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
//
// The greeting service definition.
type GreeterClient interface {
	// Sends a greeting
	SayHello(ctx context.Context, in *HelloRequest, opts ...grpc.CallOption) (*HelloReply, error)
}

type greeterClient struct {
	cc grpc.ClientConnInterface
}

func NewGreeterClient(cc grpc.ClientConnInterface) GreeterClient {
	return &greeterClient{cc}
}

func (c *greeterClient) SayHello(ctx context.Context, in *HelloRequest, opts ...grpc.CallOption) (*HelloReply, error) {
	cOpts := append([]grpc.CallOption{grpc.StaticMethod()}, opts...)
	out := new(HelloReply)
	err := c.cc.Invoke(ctx, Greeter_SayHello_FullMethodName, in, out, cOpts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}
```


Okay, this isn't really clicking so maybe I should continue with the quickstart guide.
I followed the installation instructions and when running the protoc command, I get the following error:

```bash
protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    helloworld/helloworld.proto

protoc-gen-go: program not found or is not executable
Please specify a program using absolute path or make sure the program is available in your PATH system variable
--go_out: protoc-gen-go: Plugin failed with status code 1.
```

That's pretty annoying, as I have another one installed:

```
which protoc-gen-go-grpc
/home/poko/go/bin/protoc-gen-go-grpc
```

So time to figure out where in the instructions things are broken.

