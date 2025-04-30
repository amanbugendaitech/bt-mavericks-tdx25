public with sharing class JiraProjectSummaryAction {
    
    public class Inputs {
        @InvocableVariable(required=true)
        public String projectKey;
    }

    public class Outputs {
        @InvocableVariable
        public String projectSummary;
    }

    @InvocableMethod(label='Get Jira Project Summary' description='Fetches a summary of a Jira project by project key')
    public static List<Outputs> run(List<Inputs> inputs) {
        List<Outputs> results = new List<Outputs>();

        for (Inputs input : inputs) {
            Outputs output = new Outputs();

            if (String.isEmpty(input.projectKey)) {
                output.projectSummary = 'Please provide a valid Jira project key.';
            } else {
                try {
                    output.projectSummary = JiraProjectSummaryService.getProjectSummary(input.projectKey);
                } catch (Exception e) {
                    output.projectSummary = 'Error retrieving project summary: ' + e.getMessage();
                }
            }

            results.add(output);
        }

        return results;
    }
}