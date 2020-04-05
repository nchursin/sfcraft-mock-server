public with sharing class MockAPI implements HttpCalloutMock {

    private Map<String, Resource> endpointResourceMap;
    private Integer nextResponseCode;

    public class DefaultResponse implements HttpRespondable{
        public String status;
        public DefaultResponse(String status) {
            this.status = status;
        }

        public String toResponseBody() {
            return JSON.serialize(this);
        }
    }

    public interface HttpRespondable {
        String toResponseBody();
    }

    public class Resource {
        private String endpoint;

        private Map<Integer, HttpResponse> responseMap;

        public Resource (String endpoint) {
            this.endpoint = endpoint;
            this.responseMap = new Map<Integer, HttpResponse>();
        }

        public String getEndpoint() {
            return this.endpoint;
        }

        public void setResponse(Integer statusCode, HttpRespondable responseBody) {
            HttpResponse response = new HttpResponse();
            response.setBody(responseBody.toResponseBody());
            response.setStatusCode(statusCode);
            this.responseMap.put(statusCode, response);
        }

        public HttpResponse getResponse(Integer statusCode) {
            return this.responseMap.get(statusCode);
        }
    }

    public MockAPI() {
        this.endpointResourceMap = new Map<String, Resource>();
        this.nextResponseCode = 200;
    }

    public HttpResponse respond(HttpRequest req) {
        String endpoint = req.getEndpoint();
        Resource resource = this.endpointResourceMap.get(endpoint);
        HttpResponse response = resource.getResponse(this.nextResponseCode);
        return response;
    }

    public void addEndpoint(Resource res) {
        endpointResourceMap.put(res.getEndpoint(), res);
    }

    public void respondNext(Integer statusCode) {
        this.nextResponseCode = statusCode;
    }
}
