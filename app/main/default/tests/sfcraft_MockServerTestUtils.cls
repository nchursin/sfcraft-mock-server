@isTest
@TestVisible
private class sfcraft_MockServerTestUtils {
    public static final String ENDPOINT = 'https://example.com/testEndpoint';
    public static final String ENDPOINT2 = 'https://example.com/testEndpoint2';
    public static final String ENDPOINT_NOT_FOUND = 'https://example.com/notFoundEndpoint';
    public static final String ENDPOINT_GET_PARAMS = '?id=1234';
    public static final Integer SUCCESS_CODE = 200;
    public static final Integer FAILURE_CODE = 400;
    public static final DemoResponse SUCCESS_BODY = new DemoResponse('ok');
    public static final DemoResponse FAIL_BODY = new DemoResponse('fail');
    public static final String HTTP_METHOD = 'POST';

    public static HttpRequest getTestRequest() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(sfcraft_MockServerTestUtils.ENDPOINT + sfcraft_MockServerTestUtils.ENDPOINT_GET_PARAMS);
        req.setMethod(sfcraft_MockServerTestUtils.HTTP_METHOD);
        return req;
    }

    public class DemoResponse implements sfcraft_MockableHttpResponse {
        public String status;
        public DemoResponse(String status) {
            this.status = status;
        }

        public String toResponseBody() {
            return JSON.serialize(this);
        }
    }
}
