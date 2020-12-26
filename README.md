# Salesforce Craft Mock Server

<a href="https://githubsfdeploy.herokuapp.com?owner=nchursin&repo=sfcraft-mock-server">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

Mock server is an implementation of `HttpCalloutMock` which can help you make your mocks more organized.

The mock server framework consists of the following parts:

1. `MockServer` class - the actual mock server.
1. `MockServer.APIResource` class - a class which actually represents a single resource available at some endpoint.
1. `MockServer.RequestAsserter` interface - implement it and add to a resource to run assertion "on server side".
1. `MockServer.HttpMockable` interface - implement it by class that represents you server response. E.g. you parse body into a class `ServerResponseBody`. Then you need to implement the `MockServer.HttpMockable` by it to be teach the `MockServer` to respond with it.
1. `MockServer.MockServerException` - exception that is thrown by `MockServer` in case something went wrong, e.g. misconfiguration.

### Example info

For usage examples take a look at the [`MockServer` test class](../master/app/main/mockServer/tests/Test_MockServer.cls).
