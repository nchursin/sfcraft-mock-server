# Salesforce Craft Mock Server

<a href="https://githubsfdeploy.herokuapp.com?owner=nchursin&repo=sfcraft-mock-server&ref=master">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

Mock server is an implementation of `HttpCalloutMock` which can help you make your mocks more organized.

The mock server framework consists of the following parts:

1. `sfcraft_MockServer` class - the actual mock server.
1. `sfcraft_MockAPIResource` class - a class which actually represents a single resource available at some endpoint.
1. `sfcraft_RequestAsserter` interface - implement it and add to a resource to run assertion "on server side".
1. `sfcraft_MockableHttpResponse` interface - implement it by class that represents you server response. E.g. you parse body into a class `ServerResponseBody`. Then you need to implement the `sfcraft_MockableHttpResponse` by it to be teach the `sfcraft_MockServer` to respond with it.
1. `sfcraft_MockServerException` - exception that is thrown by `sfcraft_MockServer` in case something went wrong, e.g. misconfiguration.

### Example info

For usage examples take a look at the [`sfcraft_MockServer_Examples` test class](../master/app/main/mockServer/tests/sfcraft_MockServer_Examples.cls).
