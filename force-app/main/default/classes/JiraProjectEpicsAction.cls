public with sharing class JiraProjectEpicsAction {

    public class InputValues {
        @InvocableVariable(label='Project Key' description='Key of the Jira project to fetch epics from' required=true)
        public String projectKey;
    }

    public class OutputValues {
        @InvocableVariable(label='Project Epics' description='Formatted list of epics in the project')
        public String projectEpics;
    }

    @InvocableMethod(label='Get Jira Project Epics Details' description='Returns all Epics under a Jira project')
    public static List<OutputValues> getEpics(List<InputValues> inputList) {
        List<OutputValues> results = new List<OutputValues>();

        for (InputValues input : inputList) {
            OutputValues output = new OutputValues();
            output.projectEpics = JiraProjectEpicsService.getEpicsInProject(input.projectKey);
            results.add(output);
        }

        return results;
    }
}