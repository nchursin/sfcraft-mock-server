@isTest
private class sfcraft_Test_MockServerEx {
    private static final String TEST_ENDPOINT = 'http://endpoint';
    private static final String TEST_METHOD = 'POST';
    private static final Integer TEST_CODE = 404;
    // TEST: if no message provided - throw exception

    @isTest
    private static void testCreateExceptionWithEndpointOnly() {
        String messageTemplate = 'Error for endpoint: ' + sfcraft_MockServerException.PLACEHOLDER_ENDPOINT;
        String endpoint = TEST_ENDPOINT;
        String resultMessage = messageTemplate.replace(sfcraft_MockServerException.PLACEHOLDER_ENDPOINT, endpoint);
        sfcraft_MockServerException ex = new sfcraft_MockServerException.Factory()
            .setMessage(messageTemplate)
            .setEndpoint(endpoint)
            .build();
        System.assertEquals(resultMessage, ex.getMessage());
    }

    @isTest
    private static void testCreateExceptionEndpointAndMethod() {
        String messageTemplate = 'Error for endpoint: ' + sfcraft_MockServerException.PLACEHOLDER_ENDPOINT
            + '; method: ' + sfcraft_MockServerException.PLACEHOLDER_METHOD;
        String endpoint = TEST_ENDPOINT;
        String method = TEST_METHOD;
        String resultMessage = messageTemplate
            .replace(sfcraft_MockServerException.PLACEHOLDER_ENDPOINT, endpoint)
            .replace(sfcraft_MockServerException.PLACEHOLDER_METHOD, method);
        sfcraft_MockServerException ex = new sfcraft_MockServerException.Factory()
            .setMessage(messageTemplate)
            .setEndpoint(endpoint)
            .setHttpMethod(method)
            .build();
        System.assertEquals(resultMessage, ex.getMessage());
    }

    @isTest
    private static void testCreateExceptionEndpointAndMethodAndCode() {
        String messageTemplate = 'Error for endpoint: ' + sfcraft_MockServerException.PLACEHOLDER_ENDPOINT
            + '; method: ' + sfcraft_MockServerException.PLACEHOLDER_METHOD
            + '; code: ' + sfcraft_MockServerException.PLACEHOLDER_CODE;
        String endpoint = TEST_ENDPOINT;
        String method = TEST_METHOD;
        Integer code = TEST_CODE;
        String resultMessage = messageTemplate
            .replace(sfcraft_MockServerException.PLACEHOLDER_ENDPOINT, endpoint)
            .replace(sfcraft_MockServerException.PLACEHOLDER_METHOD, method)
            .replace(sfcraft_MockServerException.PLACEHOLDER_CODE, String.valueOf(code));
        sfcraft_MockServerException ex = new sfcraft_MockServerException.Factory()
            .setMessage(messageTemplate)
            .setEndpoint(endpoint)
            .setHttpMethod(method)
            .setCode(code)
            .build();
        System.assertEquals(resultMessage, ex.getMessage());
    }

    @isTest
    private static void ifNoMessageProvidedThrowException() {
        String endpoint = TEST_ENDPOINT;
        String method = TEST_METHOD;
        Integer code = TEST_CODE;
        sfcraft_MockServerException.Factory exceptionFactory = new sfcraft_MockServerException.Factory()
            .setEndpoint(endpoint)
            .setHttpMethod(method)
            .setCode(code);
        
        try {
            exceptionFactory.build();
        } catch(IllegalArgumentException ex) {
            System.assertEquals('No template message provided for exception', ex.getMessage());
        }
    }
}
