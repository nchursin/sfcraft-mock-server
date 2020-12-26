@isTest
private class sfcraft_Test_MockServer {
    private static final String ENDPOINT = 'https://example.com/testEndpoint';
    private static final String ENDPOINT_NOT_FOUND = 'https://example.com/notFoundEndpoint';
    private static final String ENDPOINT_GET_PARAMS = '?id=1234';
    private static final Integer SUCCESS_CODE = 200;
    private static final Integer FAILURE_CODE = 400;
    private static final DefaultResponse SUCCESS_BODY = new DefaultResponse('ok');
    private static final DefaultResponse FAIL_BODY = new DefaultResponse('fail');
    private static final String DEFAULT_HTTP_METHOD = 'POST';

    private static Boolean isRequestAssertionCalled = false;

    @isTest
    private static void testAddResource() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource(ENDPOINT);
        resource.setResponse(DEFAULT_HTTP_METHOD, SUCCESS_CODE, SUCCESS_BODY);
        resource.setResponse(DEFAULT_HTTP_METHOD, FAILURE_CODE, FAIL_BODY);
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.addEndpoint(resource);

        HttpRequest req = getTestRequest();
        Integer expectedCode = 200;
        HttpResponse response = server.respond(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(SUCCESS_BODY.toResponseBody(), response.getBody());

        expectedCode = 400;
        server.setExpectedStatusCode(expectedCode);
        response = server.respond(req);
        System.assertEquals(expectedCode, response.getStatusCode());
        System.assertEquals(FAIL_BODY.toResponseBody(), response.getBody());
    }

    @isTest
    private static void testNoRespForStatusCode() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource(ENDPOINT);
        resource.setResponse(DEFAULT_HTTP_METHOD, FAILURE_CODE, SUCCESS_BODY);
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.addEndpoint(resource);

        HttpRequest req = getTestRequest();
        Integer expectedCode = SUCCESS_CODE;
        String expectedExceptionMessage = sfcraft_MockServer.createMockException(sfcraft_MockServer.MSG_NO_MOCK_FOR_CODE, ENDPOINT, String.valueOf(expectedCode)).getMessage();
        try {
            server.respond(req);
            System.assert(false, 'Exception expected');
        } catch (sfcraft_MockServer.MockServerException ex) {
            System.assertEquals(expectedExceptionMessage, ex.getMessage(), 'Another exception message expected');
        }
    }

    @isTest
    private static void testNoRespForMethod() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource(ENDPOINT);
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.addEndpoint(resource);

        HttpRequest req = getTestRequest();
        String expectedExceptionMessage = sfcraft_MockServer.createMockException(sfcraft_MockServer.MSG_NO_MOCK_FOR_METHOD, ENDPOINT, req.getMethod()).getMessage();
        try {
            server.respond(req);
            System.assert(false, 'Exception expected');
        } catch (sfcraft_MockServer.MockServerException ex) {
            System.assertEquals(expectedExceptionMessage, ex.getMessage(), 'Another exception message expected');
        }
    }

    @isTest
    private static void testNoEndpoint() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource(ENDPOINT);
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.addEndpoint(resource);

        HttpRequest req = getTestRequest();
        req.setEndpoint(ENDPOINT_NOT_FOUND);
        String expectedExceptionMessage = sfcraft_MockServer.createMockException(sfcraft_MockServer.MSG_NO_MOCK_ENDPOINT, ENDPOINT_NOT_FOUND).getMessage();
        try {
            server.respond(req);
            System.assert(false, 'Exception expected');
        } catch (sfcraft_MockServer.MockServerException ex) {
            System.assertEquals(expectedExceptionMessage, ex.getMessage(), 'Another exception message expected');
        }
    }

    @isTest
    private static void testRequestAssertion() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource(ENDPOINT);
        resource.setResponse(DEFAULT_HTTP_METHOD, SUCCESS_CODE, SUCCESS_BODY);
        resource.addAssertion(new TestRequestAssertion());
        resource.addAssertion(null);
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.addEndpoint(resource);

        server.respond(getTestRequest());

        System.assert(isRequestAssertionCalled, 'Assertion was not called');
    }

    private static HttpRequest getTestRequest() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT + ENDPOINT_GET_PARAMS);
        req.setMethod(DEFAULT_HTTP_METHOD);
        return req;
    }

    private class TestRequestAssertion implements sfcraft_MockServer.RequestAsserter {
        public void assertRequest(HttpRequest req) {
            isRequestAssertionCalled = true;
        }
    }

    private class DefaultResponse implements sfcraft_MockServer.HttpMockable {
        public String status;
        public DefaultResponse(String status) {
            this.status = status;
        }

        public String toResponseBody() {
            return JSON.serialize(this);
        }
    }
}