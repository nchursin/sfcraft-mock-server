@isTest
private class sfcraft_Test_MockServerEndpoint {
    private static final Map<String, String> CLEAN_EDNPOINT_TESTS = new Map<String, String> {
        'http://example.com' => 'http://example.com',
        'http://example.com/' => 'http://example.com',
        'http://example.com///' => 'http://example.com',
        'http://example.com/ / /' => 'http://example.com',
        'http://example.com/?id=123' => 'http://example.com',
        'http://example.com/?id=123&foo=bar' => 'http://example.com',
        'http://example.com/    ?id=123&foo=bar' => 'http://example.com',
        'http://example.com/ / ?id=123&foo=bar' => 'http://example.com'
    };

    @isTest
    private static void runCleanEdnpointTests() {
        for (String endpoint : CLEAN_EDNPOINT_TESTS.keySet()) {
            String expectedCleanEdnpoint = CLEAN_EDNPOINT_TESTS.get(endpoint);
            sfcraft_MockServerEndpoint serverEndpoint = new sfcraft_MockServerEndpoint(endpoint);
            System.assertEquals(expectedCleanEdnpoint, serverEndpoint.getCleanEndpoint(), 'Test failed: ' + endpoint);
        }
    }
}
