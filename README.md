# bt-mavericks-tdx25

##Describe your solution in 300 characters or less: 

 
Sales and Accounts teams use Tasky to access real-time PM tool data in Salesforce and Slack—Sales tracks milestones and blockers, Accounts handles billing. COOs and PMs can also view epics, tasks, and sprints, enabling full project visibility across business roles and tools. 

##Describe your solution in more detail: 

Tasky: Intelligent Project Visibility for Business Teams 

##Overview: 
 Tasky is an AgentForce-powered AI assistant that integrates seamlessly with Salesforce and Slack. It empowers Sales, Accounts, COOs, and Project Managers to access real-time data from connected project management tools like Jira—without disrupting their native workflows. 


##Key Capabilities by Role 

Sales Team: 

View project milestones, upcoming deadlines, and current blockers 

Get summarized client-ready updates based on Jira activity 

Ask natural-language questions like: 

"Hey Tasky, give me a quick status summary of project PHOENIX" 

"Are there any blockers I should be aware of?" 

"Draft an email with the project summary that can be sent to the client" 

Accounts Team: 

Access billable hours logged in the PM tool 

Generate billing summaries and attach them to invoices in Salesforce 

Get alerts for discrepancies between billing status and task completion 

Ask natural-language questions like: 

"Hey Tasky, how many hours have been logged for project PHOENIX?" 

"Break that down by resources please" 

"Draft a billing summary for the client based on the details so I can email it" 

COOs & Project Managers: 

View epics, stories, tasks, and sprint progress directly in Salesforce or Slack 

Gain real-time insight into team velocity and bottlenecks 

Align operational updates with client and financial communication 

Use the agent to proactively identify delivery risks or resourcing gaps 

 

How many agents did you build? 

 
We built 1 Tasky Agent, with multiple defined topics such as project summary, task list, epics, recent comments, and top billable projects. 

 

If more time was permitted, what features or functionality would you add? 

Custom Task Assignment & Follow-ups: 

Action: “Tasky, assign the critical bug in Project Vega to Mark and notify him.” 

What the agent does: Tasky assigns a specific task based on priority or role (e.g., a critical issue) and sends a notification via Slack to the designated person (e.g., Mark) for immediate attention. 

Advanced Task Filtering and Insights: 

Action: "Tasky, show me all overdue tasks in Project Apollo with the highest priority." 

What the agent does: Tasky fetches and filters tasks based on multiple parameters like status (overdue), priority, and project, offering insights into which tasks need immediate attention. 

Time Log Approval Workflow: 

Action: “Tasky, approve time entries for Sarah for the last 5 days.” 

What the agent does: Tasky triggers the approval process for time entries, ensuring that logged hours meet approval criteria before billing. 

Detailed Task History and Audit: 

Action: “Tasky, give me the task history for Task #2345 in Project Delta.” 

What the agent does: Tasky retrieves a complete history of actions and updates on a specific task, showing who updated it, when, and what changes were made. This can be useful for tracking progress or investigating issues. 

Milestone Progress Notifications: 

Action: “Tasky, send a progress notification for Milestone 3 in Project Orion to the Accounts team.” 

What the agent does: Tasky can notify specific teams (like Accounts or Sales) about the status of key milestones, ensuring stakeholders are always in the loop about important events or changes. 

Behavioural analytics from comment on Epic/Story/Issues/Tasks. 



Prompt Example
--------

For Sales People
 
Hey Tasky, give me give me quick status summary of project PHOENIX 

Are there any blockers I should be aware of 

Draft an email with the project summary that can be sent to client. 


  

Account People

Hey Tasky, how many hours has been logged for project PHOENIX. 

Break that down by total hours by resources. 

Draft a Billing summary for client based on the details so i can email. 


Miscellaneous

Epic Insights

“Hey Tasky, show me all Epics for the PHOENIX project, including their status.”

Task Breakdown

“Can you give me a summary of all open and in-progress task PHOENIX-25, grouped by assignee?”

Recent Activity

“What are the most recent comments or updates on project PHOENIX from the last 7 days?”

Billing Intelligence

“Top billable project from this month.”
