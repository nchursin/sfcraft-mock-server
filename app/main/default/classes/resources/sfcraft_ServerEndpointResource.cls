public class sfcraft_ServerEndpointResource {
    private String endpoint;
    private sfcraft_MockAPIResource resource;

    private Map<String, Integer> responseCodeMap;
    private Map<String, List<Integer>> responseCodeQueueMap;

    public sfcraft_ServerEndpointResource(String endpoint, sfcraft_MockAPIResource resource) {
        this.endpoint = endpoint;
        this.resource = resource;
        this.responseCodeMap = new Map<String, Integer>();
        this.responseCodeQueueMap = new Map<String, List<Integer>>();
    }

    public String getEndpoint() {
        return this.endpoint;
    }

    public sfcraft_MockAPIResource getAPIResource() {
        return this.resource;
    }

    public sfcraft_ServerEndpointResource respondWith(String method, Integer code) {
        this.responseCodeMap.put(method, code);
        return this;
    }

    public sfcraft_ServerEndpointResource respondOnceWith(String method, Integer code) {
        ensureDefaultValueInMap(this.responseCodeQueueMap, method, new List<Integer>());
        this.responseCodeQueueMap.get(method).add(code);
        return this;
    }

    public HttpResponse getResponse(HttpRequest req) {
        String method = req.getMethod();

        try {
            sfcraft_MockAPIResource resource = this.getAPIResource();
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
        Integer result = 200;
        List<Integer> codeOverrides = this.responseCodeQueueMap.get(method);
        if (null != codeOverrides && !codeOverrides.isEmpty()) {
            Integer codeIndex = 0;
            result = codeOverrides.get(codeIndex);
            codeOverrides.remove(codeIndex);
        } else if (this.responseCodeMap.containsKey(method)) {
            result = this.responseCodeMap.get(method);
        }
        return result;
    }

    private static void ensureDefaultValueInMap(Map<String, Object> theMap, String key, Object value) {
        if (null == theMap.get(key)) {
            theMap.put(key, value);
        }
    }
}