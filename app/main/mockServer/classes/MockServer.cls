public with sharing class MockServer implements HttpCalloutMock {
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

    public class MockServerException extends Exception {}

    public class APIResource {
        private String endpoint;

        private Map<String, Map<Integer, HttpResponse>> responseMap;
        private Map<Integer, HttpResponse> responseMapOld;

        public APIResource (String endpoint) {
            this.endpoint = endpoint;
            this.responseMapOld = new Map<Integer, HttpResponse>();
            this.responseMap = new Map<String, Map<Integer, HttpResponse>>();
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

    public MockServer() {
        this.endpointResourceMap = new Map<String, APIResource>();
        this.expectedStatusCode = 200;
    }

    public HttpResponse respond(HttpRequest req) {
        String endpoint = req.getEndpoint();
        String method = req.getMethod();

        APIResource resource = getAPIResource(endpoint);
        HttpResponse response = resource.getResponse(method, this.expectedStatusCode);
        return response;
    }

    private APIResource getAPIResource(String endpoint) {
        endpoint = endpoint.substringBefore('?');
        if (!this.endpointResourceMap.containsKey(endpoint)) {
            throw createMockException(MSG_NO_MOCK_ENDPOINT, endpoint);
        }
        return this.endpointResourceMap.get(endpoint);
    }

    public void addEndpoint(APIResource res) {
        endpointResourceMap.put(res.getEndpoint(), res);
    }

    public void setExpectedStatusCode(Integer statusCode) {
        this.expectedStatusCode = statusCode;
    }

    @TestVisible
    private static MockServer.MockServerException createMockException(String message, String param1) {
        return createMockException(message, new List<String> { param1 });
    }

    @TestVisible
    private static MockServer.MockServerException createMockException(String message, String param1, String param2) {
        return createMockException(message,
            new List<String> {
                param1,
                param2
            });
    }

    private static MockServer.MockServerException createMockException(String message, List<String> params) {
        String expectedMessage = String.format(
            message,
            params
        );
        return new MockServer.MockServerException(expectedMessage);
    }
}
