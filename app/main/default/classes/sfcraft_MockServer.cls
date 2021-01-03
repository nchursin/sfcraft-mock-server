@isTest
public class sfcraft_MockServer implements HttpCalloutMock {
    private Map<String, sfcraft_ServerEndpointResource> endpointResourceMap;

    public sfcraft_MockServer() {
        this.endpointResourceMap = new Map<String, sfcraft_ServerEndpointResource>();
    }

    public void setAsMock() {
        Test.setMock(HttpCalloutMock.class, this);
    }

    public HttpResponse respond(HttpRequest req) {
        String endpoint = this.getCleanEndpoint(req.getEndpoint());
        return this.getServerResource(endpoint).getResponse(req);
    }

    public void addEndpoint(String endpoint, sfcraft_MockAPIResource res) {
        sfcraft_ServerEndpointResource resourceToPut = new sfcraft_ServerEndpointResource(endpoint, res);
        this.endpointResourceMap.put(endpoint, resourceToPut);
    }

    public sfcraft_ServerEndpointResource getServerResource(String endpoint) {
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

    private String getCleanEndpoint(String endpoint) {
        return endpoint.substringBefore('?');
    }
}
