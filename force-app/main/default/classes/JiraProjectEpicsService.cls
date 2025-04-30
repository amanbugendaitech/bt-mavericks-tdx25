public with sharing class JiraProjectEpicsService {

    public class EpicInfo {
        public String name;
        public String status;
        public String sprintName;
        public Decimal timeSpentHours;

        public String format() {
            return 'Epic: ' + name + ' – ' + status + ', ' + sprintName + ', Time Spent - ' + timeSpentHours.setScale(0) + ' Hours';
        }
    }

    public static String getEpicsInProject(String projectKey) {
        String jql = 'project = ' + projectKey + ' AND issuetype = Epic';
        String searchUrl = 'https://bugendaitech-team-d3k3df9d.atlassian.net/rest/api/3/search?jql=' + EncodingUtil.urlEncode(jql, 'UTF-8') + '&maxResults=100';

        String response = JiraCalloutService.sendJiraGet(searchUrl);
        if (String.isEmpty(response)) return 'No epics found.';

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(response);
        List<Object> issues = (List<Object>) parsed.get('issues');
        List<String> output = new List<String>();

        for (Object issueObj : issues) {
            Map<String, Object> issue = (Map<String, Object>) issueObj;
            Map<String, Object> fields = (Map<String, Object>) issue.get('fields');

            EpicInfo epic = new EpicInfo();
            epic.name = (String) fields.get('summary');

            Map<String, Object> statusMap = (Map<String, Object>) fields.get('status');
            epic.status = statusMap != null ? (String) statusMap.get('name') : 'Unknown';

            // Get sprint name from customfield_10020 (adjust key per org)
            if (fields.containsKey('customfield_10020')) {
                List<Object> sprints = (List<Object>) fields.get('customfield_10020');
                if (!sprints.isEmpty()) {
                    Object sprintObj = sprints[sprints.size() - 1]; // get the latest sprint
                    if (sprintObj instanceof Map<String, Object>) {
                        Map<String, Object> sprintMap = (Map<String, Object>) sprintObj;
                        epic.sprintName = sprintMap.containsKey('name') ? (String) sprintMap.get('name') : 'Unknown Sprint';
                    } else if (sprintObj instanceof String) {
                        // fallback to string parser
                        Map<String, String> sprintParsed = parseSprintString((String) sprintObj);
                        epic.sprintName = sprintParsed.containsKey('name') ? sprintParsed.get('name') : 'Unknown Sprint';
                    }
                } else {
                    epic.sprintName = 'No Sprint';
                }
            } else {
                epic.sprintName = 'No Sprint';
            }
            // Time Spent
            epic.timeSpentHours = 0;
            String issueKey = (String) issue.get('key');
            String worklogResp = JiraCalloutService.sendJiraGet('https://bugendaitech-team-d3k3df9d.atlassian.net/rest/api/3/issue/' + issueKey + '/worklog');
            Map<String, Object> logsMap = (Map<String, Object>) JSON.deserializeUntyped(worklogResp);
            List<Object> logs = (List<Object>) logsMap.get('worklogs');
            for (Object w : logs) {
                Map<String, Object> wl = (Map<String, Object>) w;
                if (wl.containsKey('timeSpentSeconds')) {
                    epic.timeSpentHours += ((Decimal) wl.get('timeSpentSeconds')) / 3600;
                }
            }

            output.add(epic.format());
        }

        return output.isEmpty() ? 'No epics found.' : String.join(output, '\n');
    }

    private static Map<String, String> parseSprintString(String raw) {
        Map<String, String> result = new Map<String, String>();
        if (String.isEmpty(raw)) return result;
        for (String part : raw.replace(' ', '').split(',')) {
            List<String> kv = part.split('=');
            if (kv.size() == 2) {
                result.put(kv[0], kv[1]);
            }
        }
        return result;
    }

    
}