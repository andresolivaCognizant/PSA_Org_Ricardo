public class ActivityTimeline_Controller {

    @AuraEnabled
    public static List<ActivityTimeline_Model> getActivityTimeline(Id recordId)
    {    
    	System.debug('Start of ActivityTimeLine_Controller.getActivityTimeline...');
    	System.debug(':::recordId: ' + recordId);
        // Create a return List
        List<ActivityTimeline_Model> returnList = new List<ActivityTimeline_Model>();

        // Add Tasks Types
        addTasks(returnList, recordId);
        addCalls(returnList, recordId); 
        addMeetings(returnList, recordId);
        addEmails(returnList, recordId);
            
        // Sort List
        returnList.sort();
        
        System.debug(':::returnList: ' + returnList);

        return returnList; 
        
    }
    
    @AuraEnabled
    public static void addTasks(List<ActivityTimeline_Model> returnList, Id recordId)
    {  
    	System.debug('Start of ActivityTimeLine_Controller.addTasks...');
        List<Task> taskList = [select   Id, Type, Owner.Name, Status, Who.Name, Subject, Description, ActivityDate  
                               from     Task 
                               //where    Who.Id = :recordId and (Type = 'Other' OR Type = Null) 
                               //and ActivityDate != null
                               LIMIT 1 
                               ];
        
        if(taskList.size() > 0)
        {
            for(Task t: taskList)
            {
                ActivityTimeline_Model taskItem = new ActivityTimeline_Model();
                
                taskItem.RecordId = t.Id;
                taskItem.ActivityTimelineType = 'Task';
                taskItem.Subject = t.Subject;
                taskItem.Detail = t.Description;
                if (t.ActivityDate != null) {
                	taskItem.ActualDate = t.ActivityDate;
	                taskItem.ShortDate = t.ActivityDate.format();
                }
	            taskItem.Recipients = t.Who.Name;
                taskItem.Assigned = t.Owner.Name;
                
                if(t.Status=='Complete'){    
                    taskItem.Complete = true;
                }
                else{
                    taskItem.Complete = false;
                }
                returnList.add(taskItem);
            }
        }
    }
    
    @AuraEnabled
    public static void addCalls(List<ActivityTimeline_Model> returnList, Id recordId)
    { 
    	System.debug('Start of ActivityTimeLine_Controller.addCalls...');
       
        List<Task> taskList = [select   Id, Type, Owner.Name, Status, Who.Name, Subject, Description, ActivityDate  
                               from     Task 
                               //where    Who.Id = :recordId and Type= 'Call' 
                               //and ActivityDate != null
                               LIMIT 1
                               ];
               
        if(taskList.size() > 0)
        {
            for(Task t: taskList)
            {
                ActivityTimeline_Model taskItem = new ActivityTimeline_Model();
                
                taskItem.RecordId = t.Id;
                taskItem.ActivityTimelineType = 'Call';
                taskItem.Subject = t.Subject;
                taskItem.Detail = t.Description;
                taskItem.ActualDate = t.ActivityDate;
                taskItem.ShortDate = t.ActivityDate.format();
                taskItem.Recipients = t.Who.Name;
                taskItem.Assigned = t.Owner.Name;
                
                if(t.Status=='Complete'){    
                    taskItem.Complete = true;
                }
                else{
                    taskItem.Complete = false;
                }
                returnList.add(taskItem);
            }
        }
    }
    
    @AuraEnabled
    public static void addMeetings(List<ActivityTimeline_Model> returnList, Id recordId)
    { 
    	System.debug('Start of ActivityTimeLine_Controller.addMeetings...');
        List<Task> taskList = [select   Id, Type, Owner.Name, Status, Who.Name, Subject, Description, ActivityDate  
                               from     Task 
                               //where    Who.Id = :recordId and Type= 'Meeting' 
                               //and ActivityDate != null
                               LIMIT 1
                               ];
        
        if(taskList.size() > 0)
        {
            for(Task t: taskList)
            {
                ActivityTimeline_Model taskItem = new ActivityTimeline_Model();
                
                taskItem.RecordId = t.Id;
                taskItem.ActivityTimelineType = 'Meeting';
                taskItem.Subject = t.Subject;
                taskItem.Detail = t.Description;
                taskItem.ActualDate = t.ActivityDate;
                taskItem.ShortDate = t.ActivityDate.format();
                taskItem.Recipients = t.Who.Name;
                taskItem.Assigned = t.Owner.Name;
                
                if(t.Status=='Complete'){    
                    taskItem.Complete = true;
                }
                else{
                    taskItem.Complete = false;
    
                }
                returnList.add(taskItem);
            }
        }
    }
    
    @AuraEnabled
    public static void addEmails(List<ActivityTimeline_Model> returnList, Id recordId)
    { 
    	System.debug('Start of ActivityTimeLine_Controller.addEmails...');
        List<Task> taskList = [select   Id, Type, Owner.Name, Status, Who.Name, Subject, Description, ActivityDate  
                               from     Task 
                               //where    Who.Id = :recordId and Type= 'Email' 
                               //and ActivityDate != null
                               LIMIT 1
                               ];
        
        if(taskList.size() > 0)
        {
        
            for(Task t: taskList)
            {
                ActivityTimeline_Model taskItem = new ActivityTimeline_Model();
                
                taskItem.RecordId = t.Id;
                taskItem.ActivityTimelineType = 'Email';
                taskItem.Subject = t.Subject;
                taskItem.Detail = t.Description;
                taskItem.ActualDate = t.ActivityDate;
                taskItem.ShortDate = t.ActivityDate.format();
                taskItem.Recipients = t.Who.Name;
                taskItem.Assigned = t.Owner.Name;
                
                if(t.Status=='Complete'){    
                    taskItem.Complete = true;
                }
                else{
                    taskItem.Complete = false;
    
                }
                returnList.add(taskItem);
            }
        }
    }
}