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

        APIResource resource = this.getAPIResource(endpoint);
        resource.assertRequest(req);

        Integer code = this.getStatusCode(endpoint, req.getMethod());
        HttpResponse response = resource.getResponse(method, code);
        return response;
    }

    public void addEndpoint(APIResource res) {
        endpointResourceMap.put(res.getEndpoint(), res);
    }

    public void setExpectedStatusCode(String endpoint, String httpMethod, Integer statusCode) {
        if (!this.expectedStatusCodesByEndpointByMethod.containsKey(endpoint)) {
            this.expectedStatusCodesByEndpointByMethod.put(endpoint, new Map<String, Integer>());
        }
        this.expectedStatusCodesByEndpointByMethod.get(endpoint).put(httpMethod, statusCode);
    }

    public APIResource getAPIResource(String endpoint) {
        endpoint = this.getCleanEndpoint(endpoint);
        if (!this.endpointResourceMap.containsKey(endpoint)) {
            throw createMockException(MSG_NO_MOCK_ENDPOINT, endpoint);
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

    private static sfcraft_MockServer.MockServerException createMockException(String message, List<String> params) {
        String expectedMessage = String.format(
            message,
            params
        );
        return new sfcraft_MockServer.MockServerException(expectedMessage);
    }

    public interface HttpMockable {
        String toResponseBody();
    }

    public interface RequestAsserter {
        void assertRequest(HttpRequest req);
    }

    public class MockServerException extends Exception {}

    public class APIResource {
        private String endpoint;

        private Map<String, Map<Integer, HttpResponse>> responseMap;
        private List<RequestAsserter> assertions;

        public APIResource (String endpoint) {
            this.endpoint = endpoint;
            this.responseMap = new Map<String, Map<Integer, HttpResponse>>();
            this.assertions = new List<RequestAsserter>();
        }

        public String getEndpoint() {
            return this.endpoint;
        }

        public void setResponse(String method, Integer statusCode, HttpMockable responseBody) {
            this.setResponse(method, statusCode, responseBody.toResponseBody());
        }

        public void setResponse(String method, Integer statusCode, String responseBody) {
            HttpResponse response = new HttpResponse();
            response.setBody(responseBody);
            response.setStatusCode(statusCode);
            Map<Integer, HttpResponse> methodResponseMap = this.responseMap.get(method);
            if (null == methodResponseMap) {
                methodResponseMap = new Map<Integer, HttpResponse>();
                this.responseMap.put(method, methodResponseMap);
            }
            methodResponseMap.put(statusCode, response);
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
                throw createMockException(MSG_NO_MOCK_FOR_METHOD, new List<String> { this.endpoint, method });
            }
            HttpResponse result = methodResponseMap.get(statusCode);
            if (null == result) {
                throw createMockException(MSG_NO_MOCK_FOR_CODE, this.endpoint, String.valueOf(statusCode));
            }
            return result;
        }
    }
}
