@isTest
private class ChnageOwnerControllerTest{

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
        list<ChnageOwnerController.availableUserList> availableName = ChnageOwnerController.getAvailableOwnerList();
        system.assertEquals(availableName.isEmpty(),false);
    }

    @isTest static void testMethod2() {
        // Create common test accounts
        List<Case> testCases = new List<Case>();
        for(Integer i=0;i<2;i++) {
            testCases.add(new Case(Origin = 'Web'));
        }
        insert testCases ; 
        list<ChnageOwnerController.availableUserList> availableName = ChnageOwnerController.getAvailableOwnerList();
        
        ChnageOwnerController.updateOwner(testCases[0].id,availableName[0].value);
        //check the new owner assignment
        system.assertEquals([select OwnerID from case where id =:testCases[0].id limit 1].OwnerID,availableName[0].value);
        
       
    }

}