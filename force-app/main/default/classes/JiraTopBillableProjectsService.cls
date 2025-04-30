public with sharing class JiraTopBillableProjectsService {

    public static String getTopBillableProjects(Date startDate, Date endDate) {
        Map<String, Decimal> projectHours = new Map<String, Decimal>();
        String formattedStart = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        String formattedEnd = DateTime.newInstance(endDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');

        String jql = 'worklogDate >= "' + formattedStart + '" AND worklogDate <= "' + formattedEnd + '"';
        String searchUrl = 'https://bugendaitech-team-d3k3df9d.atlassian.net/rest/api/3/search?jql=' + EncodingUtil.urlEncode(jql, 'UTF-8') + '&maxResults=1000';
        String searchResp = JiraCalloutService.sendJiraGet(searchUrl);
        if (String.isEmpty(searchResp)) return 'No issues found for the specified date range.';

        Map<String, Object> parsedSearch = (Map<String, Object>) JSON.deserializeUntyped(searchResp);
        List<Object> issues = (List<Object>) parsedSearch.get('issues');

        for (Object o : issues) {
            Map<String, Object> issue = (Map<String, Object>) o;
            String issueKey = (String) issue.get('key');
            String projectKey = issueKey.split('-')[0];

            String worklogResp = JiraCalloutService.sendJiraGet('https://bugendaitech-team-d3k3df9d.atlassian.net/rest/api/3/issue/' + issueKey + '/worklog');
            if (String.isEmpty(worklogResp)) continue;

            Map<String, Object> worklog = (Map<String, Object>) JSON.deserializeUntyped(worklogResp);
            List<Object> logs = (List<Object>) worklog.get('worklogs');

            for (Object w : logs) {
                Map<String, Object> wl = (Map<String, Object>) w;

                String started = (String) wl.get('started');
                Date logDate = Date.valueOf(started.substring(0, 10));
                if (logDate < startDate || logDate > endDate) continue;

                Decimal hours = ((wl.get('timeSpentSeconds') != null) ? ((Decimal) wl.get('timeSpentSeconds')) / 3600 : 0);

                Map<String, Object> commentMap = (Map<String, Object>) wl.get('comment');
                String comment = extractTextFromDocFormat(commentMap);

                if (comment != null && comment.contains('[billable]')) {
                    projectHours.put(projectKey, projectHours.containsKey(projectKey) ? projectHours.get(projectKey) + hours : hours);
                }
            }
        }

        if (projectHours.isEmpty()) return 'No billable hours found.';

        List<ProjectHour> resultList = new List<ProjectHour>();
        for (String key : projectHours.keySet()) {
            resultList.add(new ProjectHour(key, projectHours.get(key)));
        }

        resultList.sort();

        // Return only top 3 with colors based on rank
        List<String> output = new List<String>();
        for (Integer i = 0; i < Math.min(3, resultList.size()); i++) {
            ProjectHour ph = resultList[i];
            String color = i == 0 ? 'Green' : i == 1 ? 'Yellow' : 'Red';
            output.add(ph.projectKey + ' – ' + ph.hours.setScale(2) + ' hours (' + color + ')');
        }

        return String.join(output, '\n');
    }

    public class ProjectHour implements Comparable {
        public String projectKey;
        public Decimal hours;

        public ProjectHour(String key, Decimal hrs) {
            this.projectKey = key;
            this.hours = hrs;
        }

        public Integer compareTo(Object other) {
            ProjectHour otherPh = (ProjectHour) other;
            if (this.hours > otherPh.hours) return -1;
            if (this.hours < otherPh.hours) return 1;
            return 0;
        }
    }

    private static String extractTextFromDocFormat(Map<String, Object> doc) {
        if (doc == null || !doc.containsKey('content')) return null;
        String result = '';

        List<Object> contentList = (List<Object>) doc.get('content');
        for (Object block : contentList) {
            Map<String, Object> blockMap = (Map<String, Object>) block;
            if (!blockMap.containsKey('content')) continue;

            List<Object> innerContentList = (List<Object>) blockMap.get('content');
            for (Object contentPiece : innerContentList) {
                Map<String, Object> contentMap = (Map<String, Object>) contentPiece;
                if ('text'.equals(contentMap.get('type'))) {
                    result += (String) contentMap.get('text') + ' ';
                }
            }
        }

        return result.trim();
    }

    
}