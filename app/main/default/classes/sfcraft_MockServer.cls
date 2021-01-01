public with sharing class sfcraft_MockServer implements HttpCalloutMock {
    @TestVisible
    private static final String MSG_NO_MOCK_FOR_METHOD = 'No HTTP method {1} found for the endpoint: {0}';
    @TestVisible
    private static final String MSG_NO_MOCK_FOR_CODE = 'No status code {1} found for the endpoint: {0}';
    @TestVisible
    private static final String MSG_NO_MOCK_ENDPOINT = 'No API Resource found for endpoint: {0}';

    private Map<String, APIResource> endpointResourceMap;
    private Map<String, Map<String, Integer>> expectedStatusCodesByEndpointByMethod;

    public sfcraft_MockServer() {
        this.endpointResourceMap = new Map<String, APIResource>();
        this.expectedStatusCodesByEndpointByMethod = new Map<String, Map<String, Integer>>();
    }

    public void setAsMock() {
        Test.setMock(HttpCalloutMock.class, this);
    }

    public HttpResponse respond(HttpRequest req) {
        String endpoint = this.getCleanEndpoint(req.getEndpoint());
        String method = req.getMethod();

        try {
            APIResource resource = this.getAPIResource(endpoint);
            resource.assertRequest(req);

            Integer code = this.getStatusCode(endpoint, req.getMethod());
            HttpResponse response = resource.getResponse(method, code);
            return response;
        } catch (MockServerException ex) {
            ex.setEndpoint(endpoint);
            throw ex;
        }
    }

    public void addEndpoint(String endpoint, APIResource res) {
        endpointResourceMap.put(endpoint, res);
    }

    public void setExpectedStatusCode(String endpoint, String httpMethod, Integer statusCode) {
        ensureDefaultValueInMap(this.expectedStatusCodesByEndpointByMethod, endpoint, new Map<String, Integer>());
        this.expectedStatusCodesByEndpointByMethod.get(endpoint).put(httpMethod, statusCode);
    }

    public APIResource getAPIResource(String endpoint) {
        endpoint = this.getCleanEndpoint(endpoint);
        if (!this.endpointResourceMap.containsKey(endpoint)) {
            MockServerException ex = createMockException(MSG_NO_MOCK_ENDPOINT);
            ex.setEndpoint(endpoint);
            throw ex;
        }
        return this.endpointResourceMap.get(endpoint);
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

    @TestVisible
    private static sfcraft_MockServer.MockServerException createMockException(String message, String param1) {
        return createMockException(message, new List<String> { param1 });
    }

    @TestVisible
    private static sfcraft_MockServer.MockServerException createMockException(String message, String param1, String param2) {
        return createMockException(message,
            new List<String> {
                param1,
                param2
            });
    }

    @TestVisible
    private static sfcraft_MockServer.MockServerException createMockException(String message) {
        return new sfcraft_MockServer.MockServerException(message);
    }

    private static sfcraft_MockServer.MockServerException createMockException(String message, List<String> params) {
        String expectedMessage = String.format(
            message,
            params
        );
        return new sfcraft_MockServer.MockServerException(message);
    }

    public interface MockableHttpResponse {
        String toResponseBody();
    }

    public interface RequestAsserter {
        void assertRequest(HttpRequest req);
    }

    public class MockServerException extends Exception {
        public void setEndpoint(String endpoint) {
            this.setMessage(String.format(this.getMessage(), new List<String>{
                endpoint,
                '{1}'
            }));
        }

        public void setStatusCode(Integer statusCode) {
            this.setSecondParam(String.valueOf(statusCode));
        }

        public void setHttpMethod(String method) {
            this.setSecondParam(method);
        }

        private void setSecondParam(String param) {
            this.setMessage(String.format(this.getMessage(), new List<String>{
                '{0}',
                param
            }));
        }
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
                MockServerException ex = createMockException(MSG_NO_MOCK_FOR_METHOD);
                ex.setHttpMethod(method);
                throw ex;
            }
            HttpResponse result = methodResponseMap.get(statusCode);
            if (null == result) {
                MockServerException ex = createMockException(MSG_NO_MOCK_FOR_CODE);
                ex.setStatusCode(statusCode);
                throw ex;
            }
            return result;
        }
    }

    private static void ensureDefaultValueInMap(Map<String, Object> theMap, String key, Object value) {
        if (null == theMap.get(key)) {
            theMap.put(key, value);
        }
    }
}
