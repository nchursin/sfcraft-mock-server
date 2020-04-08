@isTest
private class Test_MockServer {
    private static final String ENDPOINT = 'https://example.com/testEndpoint';
    private static final Integer SUCCESS_CODE = 200;
    private static final Integer FAILURE_CODE = 400;
    private static final DefaultResponse SUCCESS_BODY = new DefaultResponse('ok');
    private static final DefaultResponse FAIL_BODY = new DefaultResponse('fail');

    // TODO: Mock.addAPIReource should add resource to resource list
    // TODO: throw error if no resource found for specific status code

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
        
        MockServer mockServer = new MockServer();
        mockServer.addEndpoint(resource);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        HttpResponse response = mockServer.respond(req);
        System.assertEquals(200, response.getStatusCode());
        System.assertEquals(SUCCESS_BODY.toResponseBody(), response.getBody());

        // TODO: after respondNext(statusCode) respond should respond with expected status code
        mockServer.respondNext(400);
        response = mockServer.respond(req);
        System.assertEquals(400, response.getStatusCode());
        System.assertEquals(FAIL_BODY.toResponseBody(), response.getBody());
    }
}
