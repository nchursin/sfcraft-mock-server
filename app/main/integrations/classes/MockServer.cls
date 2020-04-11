public with sharing class MockServer implements HttpCalloutMock {
    @TestVisible
    private static final String MSG_NO_MOCK_FOR_CODE = 'No status code {1} found for the endpoint: {0}';
    @TestVisible
    private static final String MSG_NO_MOCK_ENDPOINT = 'No API Resource found for endpoint: {0}';

    private Map<String, APIResource> endpointResourceMap;
    private Integer expectedStatusCode;

    public interface HttpMockable {
        String toResponseBody();
    }

    public class MockException extends Exception {}

    public class APIResource {
        private String endpoint;

        private Map<Integer, HttpResponse> responseMap;

        public APIResource (String endpoint) {
            this.endpoint = endpoint;
            this.responseMap = new Map<Integer, HttpResponse>();
        }

        public String getEndpoint() {
            return this.endpoint;
        }

        public void setResponse(Integer statusCode, HttpMockable responseBody) {
            HttpResponse response = new HttpResponse();
            response.setBody(responseBody.toResponseBody());
            response.setStatusCode(statusCode);
            this.responseMap.put(statusCode, response);
        }

        public HttpResponse getResponse(Integer statusCode) {
             if (!this.responseMap.containsKey(statusCode)) {
                throw createMockException(MSG_NO_MOCK_FOR_CODE, this.endpoint, statusCode);
            }
            return this.responseMap.get(statusCode);
        }
    }

    public MockServer() {
        this.endpointResourceMap = new Map<String, APIResource>();
        this.expectedStatusCode = 200;
    }

    public HttpResponse respond(HttpRequest req) {
        String endpoint = req.getEndpoint();
        APIResource resource = getAPIResource(endpoint);
        HttpResponse response = resource.getResponse(this.expectedStatusCode);
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
    private static MockServer.MockException createMockException(String message, String endpoint) {
        return createMockException(message, endpoint, null);
    }

    @TestVisible
    private static MockServer.MockException createMockException(String message, String endpoint, Integer statusCode) {
        String expectedMessage = String.format(
            message,
            new List<String> {
                endpoint,
                String.valueOf(statusCode)
            }
        );
        return new MockServer.MockException(expectedMessage);
    }
}
