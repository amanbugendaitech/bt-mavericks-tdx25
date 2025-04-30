public with sharing class JiraTopBillableProjectAction {

    public class JiraTopBillableRequest {
        @InvocableVariable(required=true)
        public Date startDate;

        @InvocableVariable(required=true)
        public Date endDate;
    }

    public class JiraTopBillableResponse {
        @InvocableVariable
        public String topBillableSummary;
    }

    @InvocableMethod(label='Get Top 3 Billable Jira Projects' description='Returns the top 3 projects based on billable hours within a date range')
    public static List<JiraTopBillableResponse> getTopProjects(List<JiraTopBillableRequest> requests) {
        List<JiraTopBillableResponse> responses = new List<JiraTopBillableResponse>();

        for (JiraTopBillableRequest req : requests) {
            JiraTopBillableResponse res = new JiraTopBillableResponse();
            res.topBillableSummary = JiraTopBillableProjectsService.getTopBillableProjects(req.startDate, req.endDate);
            responses.add(res);
        }

        return responses;
    }
}