public with sharing class sfcraft_MockServer implements HttpCalloutMock {
    @TestVisible
    private static final String MSG_NO_MOCK_FOR_METHOD = 'No HTTP method {1} found for the endpoint: {0}';
    @TestVisible
    private static final String MSG_NO_MOCK_FOR_CODE = 'No status code {1} found for the endpoint: {0}';
    @TestVisible
    private static final String MSG_NO_MOCK_ENDPOINT = 'No API Resource found for endpoint: {0}';

    private Map<String, ServerEndpointResource> endpointResourceMap;
    private Map<String, Map<String, Integer>> expectedStatusCodesByEndpointByMethod;

    public sfcraft_MockServer() {
        this.endpointResourceMap = new Map<String, ServerEndpointResource>();
        this.expectedStatusCodesByEndpointByMethod = new Map<String, Map<String, Integer>>();
    }

    public void setAsMock() {
        Test.setMock(HttpCalloutMock.class, this);
    }

    public HttpResponse respond(HttpRequest req) {
        String endpoint = this.getCleanEndpoint(req.getEndpoint());
        return this.getServerResource(endpoint).getResponse(req);
    }

    public void addEndpoint(String endpoint, APIResource res) {
        ServerEndpointResource resourceToPut = new ServerEndpointResource(endpoint, res);
        this.endpointResourceMap.put(endpoint, resourceToPut);
    }

    public void setExpectedStatusCode(String endpoint, String httpMethod, Integer statusCode) {
        ensureDefaultValueInMap(this.expectedStatusCodesByEndpointByMethod, endpoint, new Map<String, Integer>());
        this.expectedStatusCodesByEndpointByMethod.get(endpoint).put(httpMethod, statusCode);
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

    public APIResource getAPIResource(String endpoint) {
        return this.getServerResource(endpoint).getAPIResource();
    }

    private Integer getStatusCode(String endpoint, String httpMethod) {
        Integer result = this.expectedStatusCodesByEndpointByMethod.get(endpoint)?.get(httpMethod);
        if (null == result) {
            result = 200;
        }
        return result;
    }

    private String getCleanEndpoint(String endpoint) {
        return endpoint.substringBefore('?');
    }

    private static void ensureDefaultValueInMap(Map<String, Object> theMap, String key, Object value) {
        if (null == theMap.get(key)) {
            theMap.put(key, value);
        }
    }

    public interface MockableHttpResponse {
        String toResponseBody();
    }

    public interface RequestAsserter {
        void assertRequest(HttpRequest req);
    }

    public class APIResource {
        private Map<String, Map<Integer, HttpResponse>> responseMap;
        private List<RequestAsserter> assertions;

        public APIResource () {
            this.responseMap = new Map<String, Map<Integer, HttpResponse>>();
            this.assertions = new List<RequestAsserter>();
        }

        public void setResponse(String method, Integer statusCode, MockableHttpResponse responseBody) {
            this.setResponse(method, statusCode, responseBody.toResponseBody());
        }

        public void setResponse(String method, Integer statusCode, String responseBody) {
            HttpResponse response = new HttpResponse();
            response.setBody(responseBody);
            response.setStatusCode(statusCode);
            ensureDefaultValueInMap(this.responseMap, method, new Map<Integer, HttpResponse>());
            this.responseMap.get(method).put(statusCode, response);
        }

        public void assertRequest(HttpRequest req) {
            for (RequestAsserter assertion : this.assertions) {
                assertion.assertRequest(req);
            }
        }

        public void addAssertion(RequestAsserter assertion) {
            if (null == assertion) {
                return;
            }
            this.assertions.add(assertion);
        }

        public HttpResponse getResponse(String method, Integer statusCode) {
            Map<Integer, HttpResponse> methodResponseMap = this.responseMap.get(method);
            if (null == methodResponseMap) {
                sfcraft_MockServerException ex = new sfcraft_MockServerException.Factory()
                    .setMessage(sfcraft_MockServerException.MSG_NO_MOCK_FOR_METHOD)
                    .setHttpMethod(method)
                    .build();
                throw ex;
            }
            HttpResponse result = methodResponseMap.get(statusCode);
            if (null == result) {
                sfcraft_MockServerException ex = new sfcraft_MockServerException.Factory()
                    .setMessage(sfcraft_MockServerException.MSG_NO_MOCK_FOR_CODE)
                    .setCode(statusCode)
                    .build();
                throw ex;
            }
            return result;
        }
    }

    private class ServerEndpointResource {
        private String endpoint;
        private APIResource resource;

        private Map<String, Integer> responseCodeMap;

        public ServerEndpointResource(String endpoint, sfcraft_MockServer.APIResource resource) {
            this.endpoint = endpoint;
            this.resource = resource;
            this.responseCodeMap = new Map<String, Integer>();
        }

        public String getEndpoint() {
            return this.endpoint;
        }

        public APIResource getAPIResource() {
            return this.resource;
        }

        public void respondWith(String method, Integer code) {
            this.responseCodeMap.put(method, code);
        }

        public HttpResponse getResponse(HttpRequest req) {
            String method = req.getMethod();

            try {
                APIResource resource = this.getAPIResource();
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
