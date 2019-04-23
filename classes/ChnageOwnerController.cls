/*
* ChnageOwnerController
*
* This class is used to write supporting functions for the change owner LWC
*/
public with sharing class ChnageOwnerController{
    // Get all available queues for the Case object
    //performance improvement using @AuraEnabled(cacheable=true)
    @AuraEnabled(cacheable=true)
    public static list<availableUserList> getAvailableOwnerList() {
        list<availableUserList> availableName = new list<availableUserList>();
        for(QueueSobject tempObj : [SELECT QueueId, Queue.Name, SobjectType FROM QueueSobject WHERE SobjectType = 'Case']){
            availableName.add(new availableUserList(tempObj.Queue.Name,tempObj.QueueId));
        } 
        return availableName; 
    } 
    // Method to commit owner changes to Database
    @AuraEnabled
    public static void updateOwner(String caseID, String ownerID){
        try{
            if(caseID!=null && OwnerID!=null){
                update new Case(ID=caseID, OwnerID=ownerID,ReassignedDate__c=system.TODAY());
            }
        }catch(Exception e){
            system.debug('Error :'+e);
            //TODO: Log in custom object
        }
    }
   // Class structure used by the lightning combobox 
   public class availableUserList{
        @AuraEnabled public string label;
        @AuraEnabled public string value;
        public availableUserList(string l, string v){
            label=l;
            value=v;
        }
    }
}