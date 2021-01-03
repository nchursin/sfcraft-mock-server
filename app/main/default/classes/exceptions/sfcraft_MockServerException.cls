public class sfcraft_MockServerException extends Exception {
    private static final String PLACEHOLDER = '$[{0}]';
    @TestVisible
    private static final String PLACEHOLDER_ENDPOINT = String.format(PLACEHOLDER, new List<String>{
        'endpoint'
    });
    @TestVisible
    private static final String PLACEHOLDER_METHOD = String.format(PLACEHOLDER, new List<String>{
        'method'
    });
    @TestVisible
    private static final String PLACEHOLDER_CODE = String.format(PLACEHOLDER, new List<String>{
        'code'
    });

    public static final String MSG_NO_MOCK_FOR_METHOD =
        'No HTTP method ' + PLACEHOLDER_METHOD + ' found for the endpoint: ' + PLACEHOLDER_ENDPOINT;
    public static final String MSG_NO_MOCK_FOR_CODE =
        'No status code ' + PLACEHOLDER_CODE + ' found for the endpoint: ' + PLACEHOLDER_ENDPOINT;
    public static final String MSG_NO_MOCK_ENDPOINT = 'No API Resource found for endpoint: ' +  + PLACEHOLDER_ENDPOINT;

    public class Factory {
        private String message;
        private String endpoint;
        private String method;
        private Integer code;

        public Factory setMessage(String message) {
            this.message = message;
            return this;
        }

        public Factory setEndpoint(String endpoint) {
            this.endpoint = endpoint;
            return this;
        }

        public Factory setHttpMethod(String method) {
            this.method = method;
            return this;
        }

        public Factory setCode(Integer code) {
            this.code = code;
            return this;
        }

        public sfcraft_MockServerException build() {
            String exceptionMessage = this.message;
            if (String.isBlank(exceptionMessage)) {
                throw new IllegalArgumentException('No template message provided for exception');
            }
            exceptionMessage = this.replaceParameterWithValue(exceptionMessage, PLACEHOLDER_ENDPOINT, this.endpoint);
            exceptionMessage = this.replaceParameterWithValue(exceptionMessage, PLACEHOLDER_METHOD, this.method);
            exceptionMessage = this.replaceParameterWithValue(
                exceptionMessage,
                PLACEHOLDER_CODE,
                String.valueOf(this.code)
            );
            return new sfcraft_MockServerException(exceptionMessage);
        }

        private String replaceParameterWithValue(String originalString, String placeholder, String value) {
            String result = originalString;
            if (String.isNotBlank(value)) {
                result = result.replace(placeholder, value);
            }
            return result;
        }
    }
}
