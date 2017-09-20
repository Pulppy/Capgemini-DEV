/**
 * @description Interface to call EIP for SCRUM related APIs
 */
public interface SCRUMEipCalloutHelperInf {
    List<Object> execute();
    void setEndpoint(Map<String, String> parameters);
  boolean readyForCallout();
    Dom.document getResponse();
    List<Object> processResultFromResponse(Dom.document doc);
    void processErrorFromResponse(Dom.document doc);
}