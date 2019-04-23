/**
 * Batch_CustomerNotification
 *
 * This batch class is used to send customer emails
 * ALl the customer case having ReassignedDate__c in past will be processed
 * Class is bulkified 
 * Class is scheduled to run daily at 13:00 (1 PM daily)
 * System.schedule('Batch_CustomerNotification Daily', '0 0 13 ? * * *', new Batch_CustomerNotification() );
 * batch to process pending request  
 * NI == Network international
 *  
 */
global class Batch_CustomerNotification implements Database.Batchable<sObject>,Schedulable, Database.AllowsCallouts {
     
     //Static COnstant to be changed if queue name changes
     public static map<String,string> ownerToEmailTemplateNameMap = new  map<String,string>{'First Level'=>'CustomerNotificationFirstLevel',
                                                                                            'Second Level'=>'CustomerNotificationSecondLevel' };
     /**
     * execute
     *
     * Scheduler execute method to schedule code execution
     *
     * @param SchedulableContext scheduling details
     * @return none
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this,200);
    }

    global list<String> firstLevelNotificationEmailList;
    global list<String> secondLevelNotificationEmailList;

    /**
     * start
     *
     * batch start method to define the context
     *
     * @param BatchableContext batch context
     * @return Query locator
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        firstLevelNotificationEmailList= new list<String>();
        secondLevelNotificationEmailList= new list<String>();
        Date today = Date.today();
        String query='select id,owner.Name,Account.PersonEmail__c,AccountID,ContactID from case where ReassignedDate__c < :today ';
        return Database.getQueryLocator(query);
    }
    /**
     * execute
     *
     * bacth execute method to process the records in current scope
     *
     * @param scope records in current scope
     * @return none
     */
    global void execute(Database.BatchableContext bc, List<Case> scope){
        //map of emailName to template ID
        map<string,ID> templateIDMap = new map<string,ID>();
        
        // get email template
        for(EmailTemplate tempTemplate: [Select id,name from EmailTemplate where name in :ownerToEmailTemplateNameMap.values()]){
            templateIDMap.put(tempTemplate.name,tempTemplate.id);
        }
        
        list<Messaging.SingleEmailMessage> singleEmailList = new list<Messaging.SingleEmailMessage>();
        
        for(Case cRecord : scope){
            if(cRecord.Account.PersonEmail__c!=null && ownerToEmailTemplateNameMap.containsKey(cRecord.owner.Name) && templateIDMap.containsKey(ownerToEmailTemplateNameMap.get(cRecord.owner.Name)) ){
               
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                /* code for person account enabled org 
                * Note: Add required fields to SOQL
                * semail.setToAddresses(new list<String>{cRecord.Account.PersonEmail});
                * semail.setTargetObjectId(cRecord.Account.PersonContactId);
                *
                */
                 /* code for non person accountaccount */
                semail.setToAddresses(new list<String>{cRecord.Account.PersonEmail__c});
                semail.setTargetObjectId(cRecord.ContactID);
                semail.setWhatId(cRecord.AccountID);
                
                semail.setTemplateId(templateIDMap.get(ownerToEmailTemplateNameMap.get(cRecord.owner.Name)));
                singleEmailList.add(semail);
            }
        }
        
        //update ReassignedDate__c date
        list<case> caseListToUpdate = new list<Case>();
        for(Case cRecord : scope){
            cRecord.ReassignedDate__c=null;
            caseListToUpdate.add(cRecord);
        }
        if(!caseListToUpdate.isEmpty()){update caseListToUpdate;} 
        
        if(!singleEmailList.isEmpty()){Messaging.sendEmail(singleEmailList); }
    }
    /**
     * finish
     *
     * batch finish method
     *
     * @param BatchableContext batch contect details
     * @return none
     */    
    global void finish(Database.BatchableContext bc){}    
}