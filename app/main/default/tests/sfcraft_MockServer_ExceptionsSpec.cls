@isTest
private class sfcraft_MockServer_ExceptionsSpec {
    @isTest
    private static void ifNoResponseForStatusCode_ThenServerThrowsMockServerException() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        resource.setResponse(
            sfcraft_MockServerTestUtils.HTTP_METHOD,
            sfcraft_MockServerTestUtils.FAILURE_CODE,
            sfcraft_MockServerTestUtils.SUCCESS_BODY
        );
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT, resource);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();
        Integer expectedCode = sfcraft_MockServerTestUtils.SUCCESS_CODE;
        sfcraft_MockServerException expectedException = new sfcraft_MockServerException.Factory()
            .setMessage(sfcraft_MockServerException.MSG_NO_MOCK_FOR_CODE)
            .setEndpoint(req.getEndpoint())
            .setCode(expectedCode)
            .build();
        String expectedExceptionMessage = expectedException.getMessage();

        try {
            server.respond(req);
            System.assert(false, 'Exception expected');
        } catch (sfcraft_MockServerException ex) {
            System.assertEquals(expectedExceptionMessage, ex.getMessage(), 'Another exception message expected');
        }
    }

    @isTest
    private static void ifNoResponseForMethod_ThenServerThrowsMockServerException() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT, resource);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();

        sfcraft_MockServerException expectedException = new sfcraft_MockServerException.Factory()
            .setMessage(sfcraft_MockServerException.MSG_NO_MOCK_FOR_METHOD)
            .setEndpoint(req.getEndpoint())
            .setHttpMethod(req.getMethod())
            .build();
        String expectedExceptionMessage = expectedException.getMessage();

        try {
            server.respond(req);
            System.assert(false, 'Exception expected');
        } catch (sfcraft_MockServerException ex) {
            System.assertEquals(expectedExceptionMessage, ex.getMessage(), 'Another exception message expected');
        }
    }

    @isTest
    private static void ifNoEndpointFound_ThenServerThrowsMockServerException() {
        sfcraft_MockServer.APIResource resource = new sfcraft_MockServer.APIResource();
        
        sfcraft_MockServer server = new sfcraft_MockServer();
        server.addEndpoint(sfcraft_MockServerTestUtils.ENDPOINT, resource);

        HttpRequest req = sfcraft_MockServerTestUtils.getTestRequest();
        req.setEndpoint(sfcraft_MockServerTestUtils.ENDPOINT_NOT_FOUND);

        sfcraft_MockServerException expectedException = new sfcraft_MockServerException.Factory()
            .setMessage(sfcraft_MockServerException.MSG_NO_MOCK_ENDPOINT)
            .setEndpoint(req.getEndpoint())
            .build();
        String expectedExceptionMessage = expectedException.getMessage();

        try {
            server.respond(req);
            System.assert(false, 'Exception expected');
        } catch (sfcraft_MockServerException ex) {
            System.assertEquals(expectedExceptionMessage, ex.getMessage(), 'Another exception message expected');
        }
    }
}
