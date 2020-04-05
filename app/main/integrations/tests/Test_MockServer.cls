@isTest
private class Test_MockServer {
    private static final String ENDPOINT = 'https://example.com/testEndpoint';
    private static final Integer SUCCESS_CODE = 200;
    private static final Integer FAILURE_CODE = 400;
    private static final MockAPI.DefaultResponse SUCCESS_BODY = new MockAPI.DefaultResponse('ok');
    private static final MockAPI.DefaultResponse FAIL_BODY = new MockAPI.DefaultResponse('fail');

    // TODO: Mock.addAPIReource should add resource to resource list
    // TODO: throw error if no resource found for specific status code
    // TODO: rename MockAPI to MockServer
    // TODO: rename Resource to APIResource

    @isTest
    private static void testAddResource() {
        MockAPI.Resource resource = new MockAPI.Resource(ENDPOINT);
        resource.setResponse(SUCCESS_CODE, SUCCESS_BODY);
        resource.setResponse(FAILURE_CODE, FAIL_BODY);
        
        MockAPI mockServer = new MockAPI();
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
