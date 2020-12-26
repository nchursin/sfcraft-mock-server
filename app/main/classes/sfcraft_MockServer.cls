public with sharing class sfcraft_MockServer implements HttpCalloutMock {
    @TestVisible
    private static final String MSG_NO_MOCK_FOR_METHOD = 'No HTTP method {1} found for the endpoint: {0}';
    @TestVisible
    private static final String MSG_NO_MOCK_FOR_CODE = 'No status code {1} found for the endpoint: {0}';
    @TestVisible
    private static final String MSG_NO_MOCK_ENDPOINT = 'No API Resource found for endpoint: {0}';

    private Map<String, APIResource> endpointResourceMap;
    private Integer expectedStatusCode;

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
            HttpResponse response = new HttpResponse();
            response.setBody(responseBody.toResponseBody());
            response.setStatusCode(statusCode);
            Map<Integer, HttpResponse> methodResponseMap = this.responseMap.get(method);
            if (null == methodResponseMap) {
                methodResponseMap = new Map<Integer, HttpResponse>();
                this.responseMap.put(method, methodResponseMap);
            }
            methodResponseMap.put(statusCode, response);
        }

        public void addAssertion(RequestAsserter assertion) {
            if (null == assertion) {
                return;
            }
            this.assertions.add(assertion);
        }

        public List<RequestAsserter> getAssertions() {
            return this.assertions;
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

    public sfcraft_MockServer() {
        this.endpointResourceMap = new Map<String, APIResource>();
        this.expectedStatusCode = 200;
    }

    public HttpResponse respond(HttpRequest req) {
        String endpoint = req.getEndpoint();
        String method = req.getMethod();

        APIResource resource = getAPIResource(endpoint);
        for (RequestAsserter assertion : resource.getAssertions()) {
            assertion.assertRequest(req);
        }
        HttpResponse response = resource.getResponse(method, this.expectedStatusCode);
        return response;
    }

    public void addEndpoint(APIResource res) {
        endpointResourceMap.put(res.getEndpoint(), res);
    }

    public void setExpectedStatusCode(Integer statusCode) {
        this.expectedStatusCode = statusCode;
    }

    public APIResource getAPIResource(String endpoint) {
        endpoint = endpoint.substringBefore('?');
        if (!this.endpointResourceMap.containsKey(endpoint)) {
            throw createMockException(MSG_NO_MOCK_ENDPOINT, endpoint);
        }
        return this.endpointResourceMap.get(endpoint);
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
}