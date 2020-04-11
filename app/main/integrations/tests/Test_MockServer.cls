@isTest
private class Test_MockServer {
    private static final String ENDPOINT = 'https://example.com/testEndpoint';
    private static final String ENDPOINT_NOT_FOUND = 'https://example.com/notFoundEndpoint';
    private static final String ENDPOINT_GET_PARAMS = '?id=1234';
    private static final Integer SUCCESS_CODE = 200;
    private static final Integer FAILURE_CODE = 400;
    private static final DefaultResponse SUCCESS_BODY = new DefaultResponse('ok');
    private static final DefaultResponse FAIL_BODY = new DefaultResponse('fail');

    public class DefaultResponse implements MockServer.HttpMockable {
        public String status;
        public DefaultResponse(String status) {
            this.status = status;
        }

        public String toResponseBody() {
            return JSON.serialize(this);
        }
    }

    @isTest
    private static void testAddResource() {
        MockServer.APIResource resource = new MockServer.APIResource(ENDPOINT);
        resource.setResponse(SUCCESS_CODE, SUCCESS_BODY);
        resource.setResponse(FAILURE_CODE, FAIL_BODY);
        
        MockServer server = new MockServer();
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
        MockServer.APIResource resource = new MockServer.APIResource(ENDPOINT);
        
        MockServer server = new MockServer();
        server.addEndpoint(resource);

        HttpRequest req = getTestRequest();
        Integer expectedCode = 200;
        String expectedExceptionMessage = MockServer.createMockException(MockServer.MSG_NO_MOCK_FOR_CODE, ENDPOINT, expectedCode).getMessage();
        try {
            server.respond(req);
            System.assert(false, 'Exception expected');
        } catch (MockServer.MockException ex) {
            System.assertEquals(expectedExceptionMessage, ex.getMessage(), 'Another exception message expected');
        }
    }

    @isTest
    private static void testNoEndpoint() {
        MockServer.APIResource resource = new MockServer.APIResource(ENDPOINT);
        
        MockServer server = new MockServer();
        server.addEndpoint(resource);

        HttpRequest req = getTestRequest();
        req.setEndpoint(ENDPOINT_NOT_FOUND);
        String expectedExceptionMessage = MockServer.createMockException(MockServer.MSG_NO_MOCK_ENDPOINT, ENDPOINT_NOT_FOUND).getMessage();
        try {
            server.respond(req);
            System.assert(false, 'Exception expected');
        } catch (MockServer.MockException ex) {
            System.assertEquals(expectedExceptionMessage, ex.getMessage(), 'Another exception message expected');
        }
    }

    private static HttpRequest getTestRequest() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT + ENDPOINT_GET_PARAMS);
        return req;
    }
}
