public with sharing class MockServer implements HttpCalloutMock {

    private Map<String, APIResource> endpointResourceMap;
    private Integer nextResponseCode;

    public interface HttpMockable {
        String toResponseBody();
    }

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
            return this.responseMap.get(statusCode);
        }
    }

    public MockServer() {
        this.endpointResourceMap = new Map<String, APIResource>();
        this.nextResponseCode = 200;
    }

    public HttpResponse respond(HttpRequest req) {
        String endpoint = req.getEndpoint();
        APIResource resource = this.endpointResourceMap.get(endpoint);
        HttpResponse response = resource.getResponse(this.nextResponseCode);
        return response;
    }

    public void addEndpoint(APIResource res) {
        endpointResourceMap.put(res.getEndpoint(), res);
    }

    public void respondNext(Integer statusCode) {
        this.nextResponseCode = statusCode;
    }
}
