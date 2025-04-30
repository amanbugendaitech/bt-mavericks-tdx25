public with sharing class JiraProjectTasksService {
 
    public class TaskInfo {
        public String summary;
        public String status;
        public Decimal billableHours;
        public String assignee;
 
        public String format() {
            return '“' + summary + '” – ' + status + ', ' + billableHours.setScale(0) + 'h billable' +
                (String.isNotEmpty(assignee) ? ' – Assigned to ' + assignee : '');
        }
    }
 
    public static String listTasksUnderProject(String projectKey) {
        String jql = 'project = ' + projectKey + ' AND issuetype = Task';
        String searchUrl = 'https://bugendaitech-team-d3k3df9d.atlassian.net/rest/api/3/search?jql=' + EncodingUtil.urlEncode(jql, 'UTF-8') + '&maxResults=100';
 
        String response = JiraCalloutService.sendJiraGet(searchUrl);
        if (String.isEmpty(response)) return 'No tasks found.';
 
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(response);
        List<Object> issues = (List<Object>) parsed.get('issues');
        List<String> output = new List<String>();
 
        for (Object o : issues) {
            Map<String, Object> issue = (Map<String, Object>) o;
            Map<String, Object> fields = (Map<String, Object>) issue.get('fields');
 
            TaskInfo task = new TaskInfo();
            task.summary = (String) fields.get('summary');
 
            Map<String, Object> statusMap = (Map<String, Object>) fields.get('status');
            task.status = (statusMap != null) ? (String) statusMap.get('name') : 'Unknown';
 
            Map<String, Object> assigneeMap = (Map<String, Object>) fields.get('assignee');
            task.assignee = (assigneeMap != null && assigneeMap.containsKey('displayName'))
                ? (String) assigneeMap.get('displayName')
                : 'Unassigned';
 
            String key = (String) issue.get('key');
            task.billableHours = 0;
 
            String worklogResp = JiraCalloutService.sendJiraGet('https://bugendaitech-team-d3k3df9d.atlassian.net/rest/api/3/issue/' + key + '/worklog');
            Map<String, Object> logsMap = (Map<String, Object>) JSON.deserializeUntyped(worklogResp);
            List<Object> logs = (List<Object>) logsMap.get('worklogs');
 
            for (Object w : logs) {
                Map<String, Object> wl = (Map<String, Object>) w;
                Decimal hours = ((Decimal) wl.get('timeSpentSeconds')) / 3600;
                String comment = extractTextFromDocFormat((Map<String, Object>) wl.get('comment'));
                if (comment != null && comment.contains('[billable]')) {
                    task.billableHours += hours;
                }
            }
 
            output.add(task.format());
        }
 
        // Fetch Project Engagement info from Salesforce
        String projectName = '', clientName = '', projectManager = '';
        List<Project_Engagement__c> engagements = [
            SELECT Project_Name__c, Account__c
            FROM Project_Engagement__c
            WHERE External_Project_Id__c = :projectKey
            LIMIT 1
        ];
        if (!engagements.isEmpty()) {
            Project_Engagement__c pe = engagements[0];
            projectName = pe.Project_Name__c;
            clientName = 'Allen';
            projectManager = 'Sumit Pati';
        }
 
        String header = '\nProject Name: ' + projectName +
                        '\nClient Name: ' + clientName +
                        '\nProject Manager: ' + projectManager + '\n\n';
 
        return output.isEmpty() ? 'No tasks found.' : header + String.join(output, '\n');
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