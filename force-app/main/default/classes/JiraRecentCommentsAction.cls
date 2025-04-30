public with sharing class JiraRecentCommentsAction {

    @InvocableMethod(label='Get Recent Jira Comments' description='Fetches the 5 most recent Jira comments for a given issue key')
    public static List<JiraCommentResponse> fetchComments(List<IssueKeyInput> requests) {
        List<JiraCommentResponse> responses = new List<JiraCommentResponse>();

        for (IssueKeyInput req : requests) {
            String result = JiraRecentCommentsService.getRecentComments(req.issueKey);

            JiraCommentResponse response = new JiraCommentResponse();
            response.issueKey = req.issueKey;
            response.commentsSummary = result;
            responses.add(response);
        }

        return responses;
    }

    public class IssueKeyInput {
        @InvocableVariable(required=true label='Issue Key')
        public String issueKey;
    }

    public class JiraCommentResponse {
        @InvocableVariable(label='Issue Key')
        public String issueKey;

        @InvocableVariable(label='Comments Summary')
        public String commentsSummary;
    }
}