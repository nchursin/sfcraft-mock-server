@isTest
private class sfcraft_Test_ServerEndpointResource {
    private static Integer codeCalled;

    @isTest
    private static void testConstruction() {
        String endpoint = 'http://endpoint';
        sfcraft_MockAPIResource apiResource = new sfcraft_MockAPIResource();
        sfcraft_ServerEndpointResource actualResource = new sfcraft_ServerEndpointResource(endpoint, apiResource);
        System.assertEquals(endpoint, actualResource.getEndpoint());
        System.assertEquals(apiResource, actualResource.getAPIResource());
    }

    @isTest
    private static void testGetResponse_DefaultCode() {
        String endpoint = 'http://endpoint';
        sfcraft_MockAPIResource apiResource =
            (sfcraft_MockAPIResource) Test.createStub(sfcraft_MockAPIResource.class, new MockAPIResource_Stub());
        sfcraft_ServerEndpointResource actualResource = new sfcraft_ServerEndpointResource(endpoint, apiResource);
        actualResource.getResponse(new HttpRequest());
        System.assertEquals(200, codeCalled, 'Unexpected code called');
    }

    @isTest
    private static void testGetResponse_SetResponseCode() {
        String endpoint = 'http://endpoint';
        sfcraft_MockAPIResource apiResource =
            (sfcraft_MockAPIResource) Test.createStub(sfcraft_MockAPIResource.class, new MockAPIResource_Stub());
        sfcraft_ServerEndpointResource actualResource = new sfcraft_ServerEndpointResource(endpoint, apiResource);
        actualResource.respondWith('GET', 202);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');

        actualResource.getResponse(req);
        System.assertEquals(202, codeCalled, 'Unexpected code called');
        actualResource.getResponse(req);
        System.assertEquals(202, codeCalled, 'Unexpected code called');
    }

    @isTest
    private static void testGetResponse_SetResponseCodeOnce() {
        String endpoint = 'http://endpoint';
        sfcraft_MockAPIResource apiResource =
            (sfcraft_MockAPIResource) Test.createStub(sfcraft_MockAPIResource.class, new MockAPIResource_Stub());
        sfcraft_ServerEndpointResource actualResource = new sfcraft_ServerEndpointResource(endpoint, apiResource);
        actualResource
            .respondOnceWith('GET', 400)
            .respondOnceWith('GET', 500)
            .respondWith('GET', 202);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');

        actualResource.getResponse(req);
        System.assertEquals(400, codeCalled, 'Unexpected code called');
        actualResource.getResponse(req);
        System.assertEquals(500, codeCalled, 'Unexpected code called');
        actualResource.getResponse(req);
        System.assertEquals(202, codeCalled, 'Unexpected code called');
    }

    private class MockAPIResource_Stub implements StubProvider {
        public Object handleMethodCall(Object stubbedObject,
            String stubbedMethodName,
            System.Type returnType,
            List<System.Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if ('getResponse' == stubbedMethodName) {
                codeCalled = (Integer) listOfArgs[1];
                return new HttpResponse();
            }
            return null;
        }
    }
}
