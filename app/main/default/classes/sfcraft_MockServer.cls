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
        sfcraft_MockServerEndpoint serverEndpoint = new sfcraft_MockServerEndpoint(req.getEndpoint());
        return this.getServerResource(serverEndpoint.getCleanEndpoint()).getResponse(req);
    }

    public void addEndpoint(String endpoint, sfcraft_MockAPIResource res) {
        sfcraft_MockServerEndpoint serverEndpoint = new sfcraft_MockServerEndpoint(endpoint);
        sfcraft_ServerEndpointResource resourceToPut = new sfcraft_ServerEndpointResource(endpoint, res);
        this.endpointResourceMap.put(serverEndpoint.getCleanEndpoint(), resourceToPut);
    }

    public sfcraft_ServerEndpointResource getServerResource(String endpoint) {
        sfcraft_MockServerEndpoint serverEndpoint = new sfcraft_MockServerEndpoint(endpoint);
        String cleanEndpoint = serverEndpoint.getCleanEndpoint();
        if (!this.endpointResourceMap.containsKey(cleanEndpoint)) {
            sfcraft_MockServerException ex = new sfcraft_MockServerException.Factory()
                .setMessage(sfcraft_MockServerException.MSG_NO_MOCK_ENDPOINT)
                .setEndpoint(cleanEndpoint)
                .build();
            throw ex;
        }
        return this.endpointResourceMap.get(cleanEndpoint);
    }
}
