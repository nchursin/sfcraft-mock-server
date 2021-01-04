@isTest
private class sfcraft_MockServer_Examples {
    private static Boolean isRequestAssertionCalled = false;

    @isTest
    private static void howToAddSuccessResponseToTheServerUsingResponseClass() {
        // Create resourse. Resource is basically an endpoint on your real server
        sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
        // Setting up a success response.
        // SUCCESS_BODY is an instance of a response wrapper class
        // SUCCESS_CODE is 200, which is default
        resource.setResponse(
            sfcraft_MockServerTestUtils.HTTP_METHOD,
            sfcraft_MockServerTestUtils.SUCCESS_CODE,
            sfcraft_MockServerTestUtils.SUCCESS_BODY
        );
        
        // Instantiating a server
        sfcraft_MockServer server = new sfcraft_MockServer();
        // Setting server as mock
        server.setAsMock();
        // Adding resource to server
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT, resource);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();
        Integer expectedCode = sfcraft_MockServerTestUtils.SUCCESS_CODE;
        // By default server always returns 200
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(
            sfcraft_MockServerTestUtils.SUCCESS_BODY.toResponseBody(),
            response.getBody()
        );
    }

    @isTest
    private static void howToAddSuccessResponseToTheServerWithNoBody() {
        // Create resourse. Resource is basically an endpoint on your real server
        sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
        // Setting up a success response.
        // SUCCESS_CODE is 200, which is default
        resource.setResponse(
            sfcraft_MockServerTestUtils.HTTP_METHOD,
            sfcraft_MockServerTestUtils.SUCCESS_CODE
        );
        
        // Instantiating a server
        sfcraft_MockServer server = new sfcraft_MockServer();
        // Setting server as mock
        server.setAsMock();
        // Adding resource to server
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT, resource);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();
        Integer expectedCode = sfcraft_MockServerTestUtils.SUCCESS_CODE;
        // By default server always returns 200
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(
            '',
            response.getBody()
        );
    }

    @isTest
    private static void howToAddSuccessResponseToTheServerUsingString() {
        // Create resourse. Resource is basically an endpoint on your real server
        sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
        // Setting up a success response.
        // SUCCESS_BODY is a string
        // SUCCESS_CODE is 200, which is default
        resource.setResponse(
            sfcraft_MockServerTestUtils.HTTP_METHOD,
            sfcraft_MockServerTestUtils.SUCCESS_CODE,
            'SUCCESS_BODY'
        );
        
        // Instantiating a server
        sfcraft_MockServer server = new sfcraft_MockServer();
        // Setting server as mock
        server.setAsMock();
        // Adding resource to server
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT, resource);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();
        Integer expectedCode = sfcraft_MockServerTestUtils.SUCCESS_CODE;
        // By default server always returns 200
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals('SUCCESS_BODY', response.getBody());
    }

    @isTest
    private static void howToAddFailureResponseToTheServerUsingResponseClass() {
        // Create resourse. Resource is basically an endpoint on your real server
        sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
        // Setting up a sample failure response.
        // FAIL_BODY is an instance of a response wrapper class
        // SUCCESS_CODE is 400 in this example
        resource.setResponse(
            sfcraft_MockServerTestUtils.HTTP_METHOD,
            sfcraft_MockServerTestUtils.FAILURE_CODE,
            sfcraft_MockServerTestUtils.FAIL_BODY
        );
        
        // Instantiating a server
        sfcraft_MockServer server = new sfcraft_MockServer();
        // Setting server as mock
        server.setAsMock();
        // Adding resource to server
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT, resource);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();
        Integer expectedCode = sfcraft_MockServerTestUtils.FAILURE_CODE;
        // Setting server to return 400
        server
            .getServerResource(sfcraft_MockServerTestUtils.ENDPOINT)
            .respondWith(sfcraft_MockServerTestUtils.HTTP_METHOD, expectedCode);
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(sfcraft_MockServerTestUtils.FAIL_BODY.toResponseBody(), response.getBody());

        // After you set up an expected code all the responses will respond with it
        response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(sfcraft_MockServerTestUtils.FAIL_BODY.toResponseBody(), response.getBody());
    }

    @isTest
    private static void howToAssertRequestReceivedByServer() {
        sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
        resource.setResponse(
            sfcraft_MockServerTestUtils.HTTP_METHOD,
            sfcraft_MockServerTestUtils.SUCCESS_CODE,
            sfcraft_MockServerTestUtils.SUCCESS_BODY
        );
        resource.addAssertion(new DemoRequestAssertion());
        resource.addAssertion(null);
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.setAsMock();
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT, resource);

        new Http().send(sfcraft_MockServerTestUtils.getTestRequest());

        System.assert(isRequestAssertionCalled, 'Assertion was not called');
    }

    @isTest
    private static void expectedResponseCodeIsOnlySetForSpecificEndpoint() {
        sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
        resource.setResponse(
            sfcraft_MockServerTestUtils.HTTP_METHOD,
            sfcraft_MockServerTestUtils.FAILURE_CODE,
            sfcraft_MockServerTestUtils.FAIL_BODY
        );
        sfcraft_MockAPIResource resource2 = new sfcraft_MockAPIResource();
        resource2.setResponse(
            sfcraft_MockServerTestUtils.HTTP_METHOD,
            sfcraft_MockServerTestUtils.SUCCESS_CODE,
            sfcraft_MockServerTestUtils.SUCCESS_BODY
        );
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.setAsMock();
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT, resource);
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT2, resource2);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();
        Integer expectedCode = sfcraft_MockServerTestUtils.FAILURE_CODE;
        // Setting server to return 400
        server
            .getServerResource(sfcraft_MockServerTestUtils.ENDPOINT)
            .respondWith(sfcraft_MockServerTestUtils.HTTP_METHOD, expectedCode);
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(sfcraft_MockServerTestUtils.FAIL_BODY.toResponseBody(), response.getBody());

        req.setEndpoint(sfcraft_MockServerTestUtils.ENDPOINT2);
        response = new Http().send(req);
        System.assertEquals(sfcraft_MockServerTestUtils.SUCCESS_CODE, response.getStatusCode());
        System.assertEquals(sfcraft_MockServerTestUtils.SUCCESS_BODY.toResponseBody(), response.getBody());
    }

    @isTest
    private static void expectedResponseCodeIsOnlySetForSpecificHttpMethod() {
        sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
        resource.setResponse(
            'POST',
            sfcraft_MockServerTestUtils.FAILURE_CODE,
            sfcraft_MockServerTestUtils.FAIL_BODY
        );
        resource.setResponse(
            'GET',
            sfcraft_MockServerTestUtils.SUCCESS_CODE,
            sfcraft_MockServerTestUtils.SUCCESS_BODY
        );
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.setAsMock();
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT, resource);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();
        Integer expectedCode = sfcraft_MockServerTestUtils.FAILURE_CODE;
        // Setting server to return 400
        server
            .getServerResource(sfcraft_MockServerTestUtils.ENDPOINT)
            .respondWith('POST', expectedCode);
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(sfcraft_MockServerTestUtils.FAIL_BODY.toResponseBody(), response.getBody());

        req.setMethod('GET');
        response = new Http().send(req);
        System.assertEquals(sfcraft_MockServerTestUtils.SUCCESS_CODE, response.getStatusCode());
        System.assertEquals(sfcraft_MockServerTestUtils.SUCCESS_BODY.toResponseBody(), response.getBody());
    }

    @isTest
    private static void ifEndpointSpecifiedWithoutTrailingSlash_SlashTrailedEndpointsStillWork() {
        // Create resourse. Resource is basically an endpoint on your real server
        sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
        // Setting up a success response.
        // SUCCESS_BODY is an instance of a response wrapper class
        // SUCCESS_CODE is 200, which is default
        resource.setResponse(
            sfcraft_MockServerTestUtils.HTTP_METHOD,
            sfcraft_MockServerTestUtils.SUCCESS_CODE,
            sfcraft_MockServerTestUtils.SUCCESS_BODY
        );
        
        // Instantiating a server
        sfcraft_MockServer server = new sfcraft_MockServer();
        // Setting server as mock
        server.setAsMock();
        // Adding resource to server
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT, resource);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();
        req.setEndpoint(sfcraft_MockServerTestUtils.ENDPOINT_W_TRAILING_SLASH);
        Integer expectedCode = sfcraft_MockServerTestUtils.SUCCESS_CODE;
        // By default server always returns 200
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(
            sfcraft_MockServerTestUtils.SUCCESS_BODY.toResponseBody(),
            response.getBody()
        );
    }

    @isTest
    private static void ifEndpointSpecifiedWithTrailingSlash_EndpointsWithoutItStillWork() {
        // Create resourse. Resource is basically an endpoint on your real server
        sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
        // Setting up a success response.
        // SUCCESS_BODY is an instance of a response wrapper class
        // SUCCESS_CODE is 200, which is default
        resource.setResponse(
            sfcraft_MockServerTestUtils.HTTP_METHOD,
            sfcraft_MockServerTestUtils.SUCCESS_CODE,
            sfcraft_MockServerTestUtils.SUCCESS_BODY
        );
        
        // Instantiating a server
        sfcraft_MockServer server = new sfcraft_MockServer();
        // Setting server as mock
        server.setAsMock();
        // Adding resource to server
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT_W_TRAILING_SLASH, resource);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();
        req.setEndpoint(sfcraft_MockServerTestUtils.ENDPOINT);
        Integer expectedCode = sfcraft_MockServerTestUtils.SUCCESS_CODE;
        // By default server always returns 200
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(
            sfcraft_MockServerTestUtils.SUCCESS_BODY.toResponseBody(),
            response.getBody()
        );
    }

    @isTest
    private static void ifEndpointSpecifiedWithMoreThanOneTrailingSlash_EndpointsStillWork() {
        // Create resourse. Resource is basically an endpoint on your real server
        sfcraft_MockAPIResource resource = new sfcraft_MockAPIResource();
        // Setting up a success response.
        // SUCCESS_BODY is an instance of a response wrapper class
        // SUCCESS_CODE is 200, which is default
        resource.setResponse(
            sfcraft_MockServerTestUtils.HTTP_METHOD,
            sfcraft_MockServerTestUtils.SUCCESS_CODE,
            sfcraft_MockServerTestUtils.SUCCESS_BODY
        );
        
        // Instantiating a server
        sfcraft_MockServer server = new sfcraft_MockServer();
        // Setting server as mock
        server.setAsMock();
        // Adding resource to server
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT_W_TRAILING_SLASH + '/', resource);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();
        req.setEndpoint(sfcraft_MockServerTestUtils.ENDPOINT);
        Integer expectedCode = sfcraft_MockServerTestUtils.SUCCESS_CODE;
        // By default server always returns 200
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(
            sfcraft_MockServerTestUtils.SUCCESS_BODY.toResponseBody(),
            response.getBody()
        );

        req.setEndpoint(sfcraft_MockServerTestUtils.ENDPOINT + '//');
        // By default server always returns 200
        response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(
            sfcraft_MockServerTestUtils.SUCCESS_BODY.toResponseBody(),
            response.getBody()
        );
    }

    private class DemoRequestAssertion implements sfcraft_RequestAsserter {
        public void assertRequest(HttpRequest req) {
            isRequestAssertionCalled = true;
        }
    }
}
