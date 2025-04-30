public with sharing class JiraProjectTasksAction {

    public class Request {
        @InvocableVariable(required=true)
        public String projectKey;
    }

    public class Response {
        @InvocableVariable
        public String projectTasks;
    }

    @InvocableMethod(label='Get Jira Tasks Summary' description='Returns formatted list of tasks under a Jira project including billable hours')
    public static List<Response> getTasks(List<Request> requests) {
        List<Response> results = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            res.projectTasks = JiraProjectTasksService.listTasksUnderProject(req.projectKey);
            results.add(res);
        }

        return results;
    }
}