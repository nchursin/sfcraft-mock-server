@isTest
public class sfcraft_MockAPIResource {
    private Map<String, Map<Integer, HttpResponse>> responseMap;
    private List<sfcraft_RequestAsserter> assertions;

    public sfcraft_MockAPIResource () {
        this.responseMap = new Map<String, Map<Integer, HttpResponse>>();
        this.assertions = new List<sfcraft_RequestAsserter>();
    }

    public void setResponse(String method, Integer statusCode) {
        this.setResponse(method, statusCode, '');
    }

    public void setResponse(String method, Integer statusCode, Map<String, String> headers) {
        this.setResponse(method, statusCode, '', headers);
    }

    public void setResponse(
        String method,
        Integer statusCode,
        sfcraft_MockableHttpResponse responseBody,
        Map<String, String> headers
    ) {
        this.setResponse(method, statusCode, responseBody.toResponseBody(), headers);
    }
    
    public void setResponse(String method, Integer statusCode, sfcraft_MockableHttpResponse responseBody) {
        this.setResponse(method, statusCode, responseBody.toResponseBody());
    }

    public void setResponse(String method, Integer statusCode, String responseBody) {
        this.setResponse(method, statusCode, responseBody, null);
    }
    
    public void setResponse(
        String method,
        Integer statusCode,
        String responseBody,
        Map<String, String> headers
    ) {
        HttpResponse response = this.createResponse(responseBody, statusCode, headers);

        ensureDefaultValueInMap(this.responseMap, method, new Map<Integer, HttpResponse>());
        this.responseMap.get(method).put(statusCode, response);
    }

    public void assertRequest(HttpRequest req) {
        for (sfcraft_RequestAsserter assertion : this.assertions) {
            assertion.assertRequest(req);
        }
    }

    public void addAssertion(sfcraft_RequestAsserter assertion) {
        if (null == assertion) {
            return;
        }
        this.assertions.add(assertion);
    }

    public HttpResponse getResponse(String method, Integer statusCode) {
        Map<Integer, HttpResponse> methodResponseMap = this.responseMap.get(method);
        if (null == methodResponseMap) {
            sfcraft_MockServerException ex = new sfcraft_MockServerException.Factory()
                .setMessage(sfcraft_MockServerException.MSG_NO_MOCK_FOR_METHOD)
                .setHttpMethod(method)
                .build();
            throw ex;
        }
        HttpResponse result = methodResponseMap.get(statusCode);
        if (null == result) {
            sfcraft_MockServerException ex = new sfcraft_MockServerException.Factory()
                .setMessage(sfcraft_MockServerException.MSG_NO_MOCK_FOR_CODE)
                .setCode(statusCode)
                .build();
            throw ex;
        }
        return result;
    }

    private HttpResponse createResponse(String responseBody, Integer statusCode, Map<String, String> headers) {
        HttpResponse response = new HttpResponse();
        response.setBody(responseBody);
        response.setStatusCode(statusCode);
        if (null != headers) {
            for (String header : headers.keySet()) {
                String headerValue = headers.get(header);
                response.setHeader(header, headerValue);
            }
        }
        return response;
    }

    private static void ensureDefaultValueInMap(Map<String, Object> theMap, String key, Object value) {
        if (null == theMap.get(key)) {
            theMap.put(key, value);
        }
    }
}
