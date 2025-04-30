public class ProjectEmailService {
    @InvocableMethod(label='Send Project Email' description='Sends an email with project details after confirmation.')
    public static List<Response> handleProjectEmail(List<Request> requests) {
        List<Response> results = new List<Response>();

        for (Request req : requests) {
            String projectName = req.projectName;
            Response res = new Response();

            if (String.isEmpty(projectName) || !req.confirmDraft || !req.confirmSend) {
                res.message = '⚠️ Missing input or confirmation.';
                results.add(res);
                continue;
            }

            Project_Engagement__c proj = [
                SELECT Id, Name, External_Project_Id__c, Active__c, Last_Billing_Date__c,
                       Opportunity__c, Account__c, Primary_Contact__r.Email 
                FROM Project_Engagement__c 
                WHERE Project_Name__c LIKE :projectName
                LIMIT 1
            ];

            if (proj == null) {
                res.message = '⚠️ No matching project found for "' + projectName + '".';
                results.add(res);
                continue;
            }

            String emailBody = JiraProjectSummaryService.getProjectSummary(proj.External_Project_Id__c);

            if (proj.Primary_Contact__r != null && !String.isEmpty(proj.Primary_Contact__r.Email)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { proj.Primary_Contact__r.Email });
                mail.setSubject('Project Summary: ' + proj.Name);
                mail.setPlainTextBody(emailBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

                res.message = '✅ Email sent to: ' + proj.Primary_Contact__r.Email;
            } else {
                res.message = '⚠️ No email found for the primary contact.';
            }

            results.add(res);
        }

        return results;
    }

    public class Request {
        @InvocableVariable(label='Project Name')
        public String projectName;

        @InvocableVariable(label='Confirm Draft')
        public Boolean confirmDraft;

        @InvocableVariable(label='Confirm Send')
        public Boolean confirmSend;
    }

    public class Response {
        @InvocableVariable(label='Response Message')
        public String message;
    }
}