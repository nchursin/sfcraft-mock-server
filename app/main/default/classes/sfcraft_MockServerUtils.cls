public class sfcraft_MockServerUtils {
    public static void ensureDefaultValueInMap(Map<String, Object> theMap, String key, Object value) {
        if (null == theMap.get(key)) {
            theMap.put(key, value);
        }
    }
}
