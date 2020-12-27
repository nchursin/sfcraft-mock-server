@isTest
private class sfcraft_Test_MockServer {
    private static final String ENDPOINT = 'https://example.com/testEndpoint';
    private static final String ENDPOINT2 = 'https://example.com/testEndpoint2';
    private static final String ENDPOINT_NOT_FOUND = 'https://example.com/notFoundEndpoint';
    private static final String ENDPOINT_GET_PARAMS = '?id=1234';
    private static final Integer SUCCESS_CODE = 200;
    private static final Integer FAILURE_CODE = 400;
    private static final DemoResponse SUCCESS_BODY = new DemoResponse('ok');
    private static final DemoResponse FAIL_BODY = new DemoResponse('fail');
    private static final String HTTP_METHOD = 'POST';

    private static Boolean isRequestAssertionCalled = false;

    @isTest
    private static void howToAddSuccessResponseToTheServerUsingResponseClass() {
        // Create resourse. Resource is basically an endpoint on your real server
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        // Setting up a success response.
        // SUCCESS_BODY is an instance of a response wrapper class
        // SUCCESS_CODE is 200, which is default
        resource.setResponse(HTTP_METHOD, SUCCESS_CODE, SUCCESS_BODY);
        
        // Instantiating a server
        sfcraft_MockServer server = new sfcraft_MockServer();
        // Setting server as mock
        server.setAsMock();
        // Adding resource to server
        server.addEndpoint(ENDPOINT, resource);

        HttpRequest req = getTestRequest();
        Integer expectedCode = SUCCESS_CODE;
        // By default server always returns 200
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(SUCCESS_BODY.toResponseBody(), response.getBody());
    }

    @isTest
    private static void howToAddSuccessResponseToTheServerUsingString() {
        // Create resourse. Resource is basically an endpoint on your real server
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        // Setting up a success response.
        // SUCCESS_BODY is a string
        // SUCCESS_CODE is 200, which is default
        resource.setResponse(HTTP_METHOD, SUCCESS_CODE, 'SUCCESS_BODY');
        
        // Instantiating a server
        sfcraft_MockServer server = new sfcraft_MockServer();
        // Setting server as mock
        server.setAsMock();
        // Adding resource to server
        server.addEndpoint(ENDPOINT, resource);

        HttpRequest req = getTestRequest();
        Integer expectedCode = SUCCESS_CODE;
        // By default server always returns 200
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals('SUCCESS_BODY', response.getBody());
    }

    @isTest
    private static void howToAddFailureResponseToTheServerUsingResponseClass() {
        // Create resourse. Resource is basically an endpoint on your real server
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        // Setting up a sample failure response.
        // FAIL_BODY is an instance of a response wrapper class
        // SUCCESS_CODE is 400 in this example
        resource.setResponse(HTTP_METHOD, FAILURE_CODE, FAIL_BODY);
        
        // Instantiating a server
        sfcraft_MockServer server = new sfcraft_MockServer();
        // Setting server as mock
        server.setAsMock();
        // Adding resource to server
        server.addEndpoint(ENDPOINT, resource);

        HttpRequest req = getTestRequest();
        Integer expectedCode = FAILURE_CODE;
        // Setting server to return 400
        server.setExpectedStatusCode(ENDPOINT, HTTP_METHOD, expectedCode);
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(FAIL_BODY.toResponseBody(), response.getBody());

        // After you set up an expected code all the responses will respond with it
        response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(FAIL_BODY.toResponseBody(), response.getBody());
    }

    @isTest
    private static void howToAssertRequestReceivedByServer() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        resource.setResponse(HTTP_METHOD, SUCCESS_CODE, SUCCESS_BODY);
        resource.addAssertion(new DemoRequestAssertion());
        resource.addAssertion(null);
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.setAsMock();
        server.addEndpoint(ENDPOINT, resource);

        new Http().send(getTestRequest());

        System.assert(isRequestAssertionCalled, 'Assertion was not called');
    }

    @isTest
    private static void expectedResponseCodeIsOnlySetForSpecificEndpoint() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        resource.setResponse(HTTP_METHOD, FAILURE_CODE, FAIL_BODY);
        sfcraft_MockServer.APIResource resource2 = new sfcraft_MockServer.APIResource();
        resource2.setResponse(HTTP_METHOD, SUCCESS_CODE, SUCCESS_BODY);
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.setAsMock();
        server.addEndpoint(ENDPOINT, resource);
        server.addEndpoint(ENDPOINT2, resource2);

        HttpRequest req = getTestRequest();
        Integer expectedCode = FAILURE_CODE;
        // Setting server to return 400
        server.setExpectedStatusCode(ENDPOINT, HTTP_METHOD, expectedCode);
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(FAIL_BODY.toResponseBody(), response.getBody());

        req.setEndpoint(ENDPOINT2);
        response = new Http().send(req);
        System.assertEquals(SUCCESS_CODE, response.getStatusCode());
        System.assertEquals(SUCCESS_BODY.toResponseBody(), response.getBody());
    }

    @isTest
    private static void expectedResponseCodeIsOnlySetForSpecificHttpMethod() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        resource.setResponse('POST', FAILURE_CODE, FAIL_BODY);
        resource.setResponse('GET', SUCCESS_CODE, SUCCESS_BODY);
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.setAsMock();
        server.addEndpoint(ENDPOINT, resource);

        HttpRequest req = getTestRequest();
        Integer expectedCode = FAILURE_CODE;
        // Setting server to return 400
        server.setExpectedStatusCode(ENDPOINT, 'POST', expectedCode);
        HttpResponse response = new Http().send(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(FAIL_BODY.toResponseBody(), response.getBody());

        req.setMethod('GET');
        response = new Http().send(req);
        System.assertEquals(SUCCESS_CODE, response.getStatusCode());
        System.assertEquals(SUCCESS_BODY.toResponseBody(), response.getBody());
    }

    // Exceptions
    @isTest
    private static void ifNoResponseForStatusCode_ThenServerThrowsMockServerException() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        resource.setResponse(HTTP_METHOD, FAILURE_CODE, SUCCESS_BODY);
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.addEndpoint(ENDPOINT, resource);

        HttpRequest req = getTestRequest();
        Integer expectedCode = SUCCESS_CODE;
        sfcraft_MockServer.MockServerException expectedException = sfcraft_MockServer.createMockException(sfcraft_MockServer.MSG_NO_MOCK_FOR_CODE);
        expectedException.setEndpoint(ENDPOINT);
        expectedException.setStatusCode(expectedCode);
        String expectedExceptionMessage = expectedException.getMessage();

        try {
            server.respond(req);
            System.assert(false, 'Exception expected');
        } catch (sfcraft_MockServer.MockServerException ex) {
            System.assertEquals(expectedExceptionMessage, ex.getMessage(), 'Another exception message expected');
        }
    }

    @isTest
    private static void ifNoResponseForMethod_ThenServerThrowsMockServerException() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.addEndpoint(ENDPOINT, resource);

        HttpRequest req = getTestRequest();
        sfcraft_MockServer.MockServerException expectedException = sfcraft_MockServer.createMockException(sfcraft_MockServer.MSG_NO_MOCK_FOR_METHOD);
        expectedException.setEndpoint(ENDPOINT);
        expectedException.setHttpMethod(req.getMethod());
        String expectedExceptionMessage = expectedException.getMessage();

        try {
            server.respond(req);
            System.assert(false, 'Exception expected');
        } catch (sfcraft_MockServer.MockServerException ex) {
            System.assertEquals(expectedExceptionMessage, ex.getMessage(), 'Another exception message expected');
        }
    }

    @isTest
    private static void ifNoEndpointFound_ThenServerThrowsMockServerException() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.addEndpoint(ENDPOINT, resource);

        HttpRequest req = getTestRequest();
        req.setEndpoint(ENDPOINT_NOT_FOUND);
        sfcraft_MockServer.MockServerException expectedException = sfcraft_MockServer.createMockException(sfcraft_MockServer.MSG_NO_MOCK_ENDPOINT);
        expectedException.setEndpoint(ENDPOINT_NOT_FOUND);
        String expectedExceptionMessage = expectedException.getMessage();

        try {
            server.respond(req);
            System.assert(false, 'Exception expected');
        } catch (sfcraft_MockServer.MockServerException ex) {
            System.assertEquals(expectedExceptionMessage, ex.getMessage(), 'Another exception message expected');
        }
    }

    private static HttpRequest getTestRequest() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT + ENDPOINT_GET_PARAMS);
        req.setMethod(HTTP_METHOD);
        return req;
    }

    private class DemoRequestAssertion implements sfcraft_MockServer.RequestAsserter {
        public void assertRequest(HttpRequest req) {
            isRequestAssertionCalled = true;
        }
    }

    private class DemoResponse implements sfcraft_MockServer.HttpMockable {
        public String status;
        public DemoResponse(String status) {
            this.status = status;
        }

        public String toResponseBody() {
            return JSON.serialize(this);
        }
    }
}
