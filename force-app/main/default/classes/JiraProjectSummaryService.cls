public with sharing class JiraProjectSummaryService {
 
    public class ProjectSummary {
        public String status;
        public Decimal billableHours;
        public Decimal nonBillableHours;
        public String owner;
        public String health;
        public String comments;
        public String blockedIssueKey;
        public String expectedResolution;
        public String projectName;
        public Integer resolvedIssues = 0;
        public Integer unresolvedIssues = 0;
 
        public String toAgentForceFormat() {
            return 'Project ' + projectName + ' is being managed by ' + owner + '. So far, the team has logged '
                + billableHours.setScale(0) + ' billable hours and ' + nonBillableHours.setScale(0) + ' non-billable hours. '
                + 'There are ' + resolvedIssues + ' resolved and ' + unresolvedIssues + ' unresolved issues. '
                + 'The project health is currently ' + status
                + 'Overall, the project is ' + (status == 'Green' ? 'on track.' : status == 'Yellow' ? 'slightly delayed.' : 'at risk.') +' Recent Comment: ' + 'third party API credentials are pending and will get from client by may 1.';
        }
    }
 
    public static String getProjectSummary(String projectKey) {
        ProjectSummary summary = new ProjectSummary();
 
        // 1. Get project details
        String projectResp = JiraCalloutService.sendJiraGet('https://bugendaitech-team-d3k3df9d.atlassian.net/rest/api/3/project/' + projectKey);
        if (String.isEmpty(projectResp)) return 'Project not found.';
        Map<String, Object> proj = (Map<String, Object>) JSON.deserializeUntyped(projectResp);
        summary.status = ' '; // Default, will be calculated later
        Map<String, Object> lead = (Map<String, Object>) proj.get('lead');
        summary.owner = (lead != null && lead.containsKey('displayName')) ? (String) lead.get('displayName') : 'Unknown';
        summary.projectName = (String) proj.get('name');
 
        // 2. Get issues and worklogs
        String jql = 'project = ' + projectKey;
        String issueResp = JiraCalloutService.sendJiraGet('https://bugendaitech-team-d3k3df9d.atlassian.net/rest/api/3/search?jql=' + EncodingUtil.urlEncode(jql, 'UTF-8') + '&maxResults=100');
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(issueResp);
        List<Object> issues = (List<Object>) parsed.get('issues');
        List<String> commentsList = new List<String>();
        summary.billableHours = 0;
        summary.nonBillableHours = 0;
 
        for (Object obj : issues) {
            Map<String, Object> issue = (Map<String, Object>) obj;
            String key = (String) issue.get('key');
 
            Map<String, Object> fields = (Map<String, Object>) issue.get('fields');
            if (fields != null && fields.containsKey('status')) {
                Map<String, Object> statusMap = (Map<String, Object>) fields.get('status');
                String state = (String) statusMap.get('name');
                if (!'Done'.equalsIgnoreCase(state)) {
                    summary.unresolvedIssues++;
                } else {
                    summary.resolvedIssues++;
                }
                if ('Blocked'.equalsIgnoreCase(state) && summary.blockedIssueKey == null) {
                    summary.blockedIssueKey = key;
                    summary.expectedResolution = Date.today().addDays(2).format(); // Placeholder
                }
            }
 
            // Worklogs
            String worklogResp = JiraCalloutService.sendJiraGet('https://bugendaitech-team-d3k3df9d.atlassian.net/rest/api/3/issue/' + key + '/worklog');
            Map<String, Object> logsMap = (Map<String, Object>) JSON.deserializeUntyped(worklogResp);
            List<Object> logs = (List<Object>) logsMap.get('worklogs');
 
            for (Object l : logs) {
                Map<String, Object> wl = (Map<String, Object>) l;
                Decimal hours = ((wl.get('timeSpentSeconds') != null) ? ((Decimal) wl.get('timeSpentSeconds')) / 3600 : 0);
 
                String comment = extractTextFromDocFormat((Map<String, Object>) wl.get('comment'));
                if (comment != null && comment.contains('[billable]')) {
                    summary.billableHours += hours;
                } else {
                    summary.nonBillableHours += hours;
                }
 
                if (!String.isEmpty(comment)) commentsList.add(comment);
            }
        }
 
        // 3. Project Status and Health
        if (summary.unresolvedIssues > 15) {
            summary.status = 'Red';
        } else if (summary.unresolvedIssues > 5) {
            summary.status = 'Yellow';
        } else {
            summary.status = 'Green';
        }
 
        summary.health = summary.status + ' (' + summary.unresolvedIssues + ' unresolved issues, sprint delayed)';
        summary.comments = commentsList.isEmpty() ? 'No recent comments.' : commentsList[0];
 
        return summary.toAgentForceFormat();
    }
 
    private static String extractTextFromDocFormat(Map<String, Object> doc) {
        if (doc == null || !doc.containsKey('content')) return null;
        String result = '';
        for (Object block : (List<Object>) doc.get('content')) {
            Map<String, Object> blockMap = (Map<String, Object>) block;
            if (blockMap.containsKey('content')) {
                for (Object contentPiece : (List<Object>) blockMap.get('content')) {
                    Map<String, Object> innerMap = (Map<String, Object>) contentPiece;
                    if ('text'.equals(innerMap.get('type'))) {
                        result += (String) innerMap.get('text') + ' ';
                    }
                }
            }
        }
        return result.trim();
    }
}