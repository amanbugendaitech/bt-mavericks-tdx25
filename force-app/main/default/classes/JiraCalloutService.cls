public with sharing class JiraCalloutService {
    
    // Reusable method to send GET request to Jira
    public static String sendJiraGet(String url) {
        // Fetch credentials from Custom Metadata
        Jira_Credential__mdt cred = [
            SELECT Username__c, AccessToken__c
            FROM Jira_Credential__mdt
            WHERE DeveloperName = 'API_Credential'
            LIMIT 1
        ];
        
        // Prepare HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(
            Blob.valueOf(cred.Username__c + ':' + cred.AccessToken__c)
        ));
        req.setHeader('Accept', 'application/json');

        // Send request
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Handle response
        if (res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            // You might want to log this or throw an error
            System.debug('Jira GET call failed: ' + res.getStatusCode() + ' ' + res.getBody());
            return null;
        }
    }
}