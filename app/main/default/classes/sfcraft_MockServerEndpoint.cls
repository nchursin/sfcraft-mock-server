public class sfcraft_MockServerEndpoint {
    private String originalEndpoint;

    public sfcraft_MockServerEndpoint(String originalEndpoint) {
        this.originalEndpoint = originalEndpoint;
    }

    public String getCleanEndpoint() {
        String result = this.originalEndpoint.substringBefore('?').trim();
        while (result.endsWith('/')) {
            result = result.left(result.length() - 1).trim();
        }
        return result;
    }
}
