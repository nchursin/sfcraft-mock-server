# Salesforce Craft Mock Server

<a href="https://githubsfdeploy.herokuapp.com?owner=nchursin&repo=sfcraft-mock-server&ref=master">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

Mock server is an implementation of `HttpCalloutMock` which can help you make your mocks more organized.

The mock server framework consists of the following main parts:

1. `sfcraft_MockServer` class - the actual mock server.
1. `sfcraft_MockAPIResource` class - a class which actually represents a single resource that has handles responses. Not attached to a specific endpoint.
1. `sfcraft_ServerEndpointResource` class - a class which actually represents a connection between API resource and endpoint. Dictates which code should a resource respond with. So you can have a single resource with the same responses, but different behavoiur in terms of endpoint and response codes.
1. `sfcraft_RequestAsserter` interface - implement it and add to a resource to run assertion "on server side".
1. `sfcraft_MockableHttpResponse` interface - implement it by class that represents you server response. E.g. you parse body into a class `ServerResponseBody`. Then you need to implement the `sfcraft_MockableHttpResponse` by it to be teach the `sfcraft_MockServer` to respond with it.
1. `sfcraft_MockServerException` - exception that is thrown by `sfcraft_MockServer` in case something went wrong, e.g. misconfiguration.

### Example info

#### Basic usage

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
