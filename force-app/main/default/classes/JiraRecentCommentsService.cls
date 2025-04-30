public with sharing class JiraRecentCommentsService {

    public static String getRecentComments(String issueKey) {
        if (String.isBlank(issueKey)) {
            return 'Issue key is required.';
        }

        String url = 'https://bugendaitech-team-d3k3df9d.atlassian.net/rest/api/3/issue/' + issueKey + '/comment';
        String response = JiraCalloutService.sendJiraGet(url);

        if (String.isEmpty(response)) {
            return 'No response from Jira.';
        }

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(response);
        List<Object> comments = (List<Object>) parsed.get('comments');

        if (comments == null || comments.isEmpty()) {
            return 'No comments found for ' + issueKey;
        }

        comments.sort(new JiraCommentSorter());

        List<String> lines = new List<String>();
        Integer count = 0;
        for (Object c : comments) {
            if (count >= 5) break;

            Map<String, Object> comment = (Map<String, Object>) c;
            Map<String, Object> author = (Map<String, Object>) comment.get('author');
            String authorName = (String) author.get('displayName');
            String created = ((String) comment.get('created')).substring(0, 10);

            Map<String, Object> body = (Map<String, Object>) comment.get('body');
            String summary = extractTextFromDocFormat(body);

            lines.add(created + ' – ' + authorName + ': ' + summary);
            count++;
        }

        return String.join(lines, '\n');
    }

    public class JiraCommentSorter implements Comparator<Object> {
        public Integer compare(Object a, Object b) {
            Map<String, Object> ca = (Map<String, Object>) a;
            Map<String, Object> cb = (Map<String, Object>) b;
            String da = (String) ca.get('created');
            String db = (String) cb.get('created');
            return db.compareTo(da); // descending
        }
    }

    private static String extractTextFromDocFormat(Map<String, Object> doc) {
        if (doc == null || !doc.containsKey('content')) return '';
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