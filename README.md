# SalesforceCraft Http Mock Server

<a href="https://githubsfdeploy.herokuapp.com?owner=nchursin&repo=sfcraft-mock-server&ref=master">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

Mock server is an implementation of `HttpCalloutMock` which can help you make your mocks more organized.

## How to use it

## Creating server

Server constructor takes no params. Also, you can set it as a mock right away:

```java
// Instantiating a server
sfcraft_MockServer server = new sfcraft_MockServer();
// Setting server as mock
server.setAsMock();
```

Then you need to add resources to endpoints (see below on how to create resources):
```java
server.addEndpoint('http://example.com', rootResource);
server.addEndpoint('http://example.com/users', usersResource);
```

By default they all will respond with provided 200 responses. You need explicitly ask server to respond differently:

```java
server.getServerResource('http://example.com').respondWith(400);
```

Resource attached to the endpoint must have the asked for status code. Otherwise you'll get a MockServerException.

You can also chain response codes:
```java
server.getServerResource('http://example.com')
    .respondOnceWith(400)
    .respondOnceWith(500)
    .respondWith(200);
```
You can omit `.respondWith(200)`. The resource will fallback to code 200 in case it runs out of overrides.

### Creating a resource

First instantiate a new API resource

```java
sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
```

Then you can add responses to it. To add a response you need to provide method, code, and response body.

```java
// Successful POST response
resource.setResponse(
            'POST',
            200,
            successResponseObject
        );

// Failed GET response
resource.setResponse(
            'POST',
            405,
            failResponseObject
        );
```

You can provide either response objects to set response:
```java
    public class DemoResponse implements sfcraft_MockableHttpResponse {
        public String toResponseBody() {
            return JSON.serialize(this);
        }
    }

    ...

    resource.setResponse(
        'POST',
        200,
        new DemoResponse()
    );
```
or plain strings
```java
resource.setResponse(
        'POST',
        200,
        'status: ok'
    );
```

You can also specify headers for responses if you have any logic based on those:
```java
resource.setResponse(
        'POST',
        200,
        'status: ok',
        new Map<String, String> {
            'Content-Type' => 'plain/text'
        }
    );
```

### Asserting requests
You can validate that request is built correctly. This might be helpful to test headers, e.g. `Authorization`, `Content-Type`, etc. To preform assertiong on the request you need to implement a `sfcraft_RequestAsserter` interface. Here's a sample of an assertion that checks `Content-Type` header.

```java
private class ContentTypeAssertion implements sfcraft_RequestAsserter {
    private String expectedContentType;
    public ContentTypeAssertion(String expectedContentType) {
        this.expectedContentType = expectedContentType;
    }

    public void assertRequest(HttpRequest req) {
        String contentType = req.getHeader('Content-Type');
        System.assert(String.isNotBlank(), 'Content-Type header is not set')
        System.assertEquals(this.expectedContentType, contentType, 'Content-Type is different from expected');
    }
}
```

Then you need to add these assertions to a resource:
```java
sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
resource.addAssertion(new ContentTypeJsonAssertion('application/json'));
```

You can add as many assertions as you want. They are executed in the order you add them.

```java
sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
resource.addAssertion(new AuthorizationAssertion());
resource.addAssertion(new ContentTypeJsonAssertion('application/json'));
resource.addAssertion(new BodyParamsAssertion());
resource.addAssertion(new SomeOtherAssertion());
```

## Simple 200 response test

```java
@isTest
private class BasicUsage {
    @isTest
    private static void howToUseMockServer() {
        // Create resourse. Resource is basically an endpoint on your real server
        sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
        // Setting up a success response.
        DemoResponse responseObject = new DemoResponse();
        resource.setResponse(
            'POST',
            200,
            responseObject
        );
        
        // Instantiating a server
        sfcraft_MockServer server = new sfcraft_MockServer();
        // Setting server as mock
        server.setAsMock();
        // Adding resource to server
        server.addEndpoint('http://example.com', resource);

        Test.startTest();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('http://example.com?id=1234');
            req.setMethod('GET');
            HttpResponse response = new Http().send(req);
        Test.stopTest();

        // By default server always returns 200
        System.assertEquals(200, response.getStatusCode());
        System.assertEquals(responseObject.toResponseBody(), response.getBody());
    }

    public class DemoResponse implements sfcraft_MockableHttpResponse {
        public String status;
        public DemoResponse(String status) {
            this.status = status;
        }

        public String toResponseBody() {
            return JSON.serialize(this);
        }
    }
}
```

For more usage examples take a look at the test classes. The lib is developed via TDD, which makes tests behave as specs.
## What's inside

The mock server framework consists of the following main parts:

1. `sfcraft_MockServer` class - the actual mock server.
1. `sfcraft_MockAPIResource` class - a class which actually represents a single resource that has handles responses. Not attached to a specific endpoint.
1. `sfcraft_ServerEndpointResource` class - a class which actually represents a connection between API resource and endpoint. Dictates which code should a resource respond with. So you can have a single resource with the same responses, but different behavoiur in terms of endpoint and response codes.
1. `sfcraft_RequestAsserter` interface - implement it and add to a resource to run assertion "on server side".
1. `sfcraft_MockableHttpResponse` interface - implement it by class that represents you server response. E.g. you parse body into a class `ServerResponseBody`. Then you need to implement the `sfcraft_MockableHttpResponse` by it to be teach the `sfcraft_MockServer` to respond with it.
1. `sfcraft_MockServerException` - exception that is thrown by `sfcraft_MockServer` in case something went wrong, e.g. misconfiguration.

All classes except Exception are marked as isTest. It is only used once actually to allow MockServer construct sfcraft_ServerEndpointResource without exposing its constructor. Just not to encourage peopl to construct those themselves. They are of no use outside the server as far as I'm concerned
