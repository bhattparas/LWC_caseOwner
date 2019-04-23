@isTest
private class Batch_CustomerNotificationTest{

    @testSetup static void setup() {
        // Creating Queue
        list<Group> groupList = new list<Group>{new Group(Name='First Level', Type='Queue'),
                                                new Group(Name='Second Level', Type='Queue')};
               
        insert groupList;
        
        list<QueueSObject> queueList = new list<QueueSObject>();
        for(Group g : groupList){
            queueList.add(new QueueSObject(QueueID = g.id, SObjectType = 'Case'));
        }
        
        insert queueList;
    }
    
    

    @isTest static void testMethod1() {
        // Create common test accounts
        List<Case> testCases = new List<Case>();
        for(Integer i=0;i<2;i++) {
            testCases.add(new Case(Origin = 'Web', ReassignedDate__c =system.today().addDays(-15)));
        }
        insert testCases ; 
        
        
        test.startTest();
            Database.executeBatch(new Batch_CustomerNotification());
        test.stopTest();
        
       
    }
    
    @isTest static void testMethod2() {
        // Create common test accounts
        List<Case> testCases = new List<Case>();
        for(Integer i=0;i<2;i++) {
            testCases.add(new Case(Origin = 'Web', ReassignedDate__c =system.today().addDays(-15)));
        }
        insert testCases ; 
        
       
        test.startTest();
            System.schedule('Batch_CustomerNotification','0 0 13 ? * * *', new Batch_CustomerNotification() );
        test.stopTest();
        
       
    }

}