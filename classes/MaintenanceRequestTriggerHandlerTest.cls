@isTest
public class MaintenanceRequestTriggerHandlerTest {
    @testSetup
    static void setup() {
        // Create test vendors
        Vendor__c vendor1 = new Vendor__c(Name = 'Vendor 1');
        Vendor__c vendor2 = new Vendor__c(Name = 'Vendor 2');
        Vendor__c vendor3 = new Vendor__c(Name = 'Vendor 3');
        insert new List<Vendor__c> { vendor1, vendor2, vendor3 };
        
        // Create existing maintenance requests to simulate workload
        Maintenance_Request__c request1 = new Maintenance_Request__c(Vendor__c = vendor1.Id,Status__c = 'Completed');
        Maintenance_Request__c request2 = new Maintenance_Request__c(Vendor__c = vendor2.Id,Status__c = 'In Progress');
        Maintenance_Request__c request3 = new Maintenance_Request__c(Vendor__c = vendor2.Id, Status__c = 'Open');
        insert new List<Maintenance_Request__c> { request1, request2, request3 };
    }
    
    @isTest
    static void testBeforeInsert() {
        // Create new maintenance requests
        List<Maintenance_Request__c> newRequests = new List<Maintenance_Request__c>();
        for (Integer i = 0; i < 200; i++) {
            newRequests.add(new Maintenance_Request__c());
        }
        
        // Start test context
        Test.startTest();
        
        // Insert new maintenance requests
        insert newRequests;
        
        // Stop test context
        Test.stopTest();
        
        // Verify that maintenance requests were assigned to vendors in a round-robin fashion
        Set<Id> vendorIds = new Set<Id>();
        for (Maintenance_Request__c request : [SELECT Id, Vendor__c FROM Maintenance_Request__c WHERE Id IN :newRequests]) {
            vendorIds.add(request.Vendor__c);
        }
        
        // Verify that all vendors were assigned at least one request
        System.assertEquals(3, vendorIds.size(), 'All vendors should have been assigned at least one request.');
    }
    
    @isTest
    static void testNoVendors() {
        // Delete all vendors to simulate no vendors scenario
        delete [SELECT Id FROM Vendor__c];

        List<Maintenance_Request__c> newRequests = new List<Maintenance_Request__c>();
        for (Integer i = 0; i < 3; i++) {
            newRequests.add(new Maintenance_Request__c());
        }
        
        Test.startTest();
        // Insert new maintenance requests
        try {
            insert newRequests;
            System.assert(false, 'Insert should have failed due to no vendors.');
        } catch (DmlException e) {
            System.assert(true, 'Insert failed as expected due to no vendors.');
        }
        // Stop test context
        Test.stopTest();
    }
}