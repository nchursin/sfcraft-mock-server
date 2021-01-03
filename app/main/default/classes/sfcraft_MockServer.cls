public with sharing class sfcraft_MockServer implements HttpCalloutMock {
    @TestVisible
    private static final String MSG_NO_MOCK_FOR_METHOD = 'No HTTP method {1} found for the endpoint: {0}';
    @TestVisible
    private static final String MSG_NO_MOCK_FOR_CODE = 'No status code {1} found for the endpoint: {0}';
    @TestVisible
    private static final String MSG_NO_MOCK_ENDPOINT = 'No API Resource found for endpoint: {0}';

    private Map<String, ServerEndpointResource> endpointResourceMap;

    public sfcraft_MockServer() {
        this.endpointResourceMap = new Map<String, ServerEndpointResource>();
    }

    public void setAsMock() {
        Test.setMock(HttpCalloutMock.class, this);
    }

    public HttpResponse respond(HttpRequest req) {
        String endpoint = this.getCleanEndpoint(req.getEndpoint());
        return this.getServerResource(endpoint).getResponse(req);
    }

    public void addEndpoint(String endpoint, sfcraft_MockAPIResource res) {
        ServerEndpointResource resourceToPut = new ServerEndpointResource(endpoint, res);
        this.endpointResourceMap.put(endpoint, resourceToPut);
    }

    public void setExpectedStatusCode(String endpoint, String httpMethod, Integer statusCode) {
        this.getServerResource(endpoint).respondWith(httpMethod, statusCode);
    }

    private ServerEndpointResource getServerResource(String endpoint) {
        endpoint = this.getCleanEndpoint(endpoint);
        if (!this.endpointResourceMap.containsKey(endpoint)) {
            sfcraft_MockServerException ex = new sfcraft_MockServerException.Factory()
                .setMessage(sfcraft_MockServerException.MSG_NO_MOCK_ENDPOINT)
                .setEndpoint(endpoint)
                .build();
            throw ex;
        }
        return this.endpointResourceMap.get(endpoint);
    }

    public sfcraft_MockAPIResource getAPIResource(String endpoint) {
        return this.getServerResource(endpoint).getAPIResource();
    }

    private String getCleanEndpoint(String endpoint) {
        return endpoint.substringBefore('?');
    }

    private class ServerEndpointResource {
        private String endpoint;
        private sfcraft_MockAPIResource resource;

        private Map<String, Integer> responseCodeMap;

        public ServerEndpointResource(String endpoint, sfcraft_MockAPIResource resource) {
            this.endpoint = endpoint;
            this.resource = resource;
            this.responseCodeMap = new Map<String, Integer>();
        }

        public String getEndpoint() {
            return this.endpoint;
        }

        public sfcraft_MockAPIResource getAPIResource() {
            return this.resource;
        }

        public void respondWith(String method, Integer code) {
            this.responseCodeMap.put(method, code);
        }

        public HttpResponse getResponse(HttpRequest req) {
            String method = req.getMethod();

            try {
                sfcraft_MockAPIResource resource = this.getAPIResource();
                resource.assertRequest(req);

                Integer code = this.getResponseCode(req.getMethod());
                HttpResponse response = resource.getResponse(method, code);
                return response;
            } catch (sfcraft_MockServerException ex) {
                sfcraft_MockServerException newEx = new sfcraft_MockServerException.Factory()
                    .setMessage(ex.getMessage())
                    .setEndpoint(req.getEndpoint())
                    .build();
                ex.setMessage(newEx.getMessage());
                throw ex;
            }
        }

        private Integer getResponseCode(String method) {
            return this.responseCodeMap.containsKey(method)
                ? this.responseCodeMap.get(method)
                : 200;
        }
        // TODO: use this class everywhere and add here API for response codes
    }
}
