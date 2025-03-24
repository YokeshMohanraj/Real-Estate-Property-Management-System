@isTest
public class LeaseAgreementControllerTest{
    @TestSetup
    static void makeData() {
        Tenant__c tenant = new Tenant__c(
            Name = 'Test Tenant',
            Email__c = 'tenant@test.com'
        );
        INSERT tenant;
        
        Property__c property = new Property__c(
            Name = 'Test Property', Tenant__c = tenant.Id , Description__c = 'Test Record' ,Status__c = 'Occupied' ,Type__c = 'Residential',Postal_Code__c = '603203',City__c= 'Chennai' , State__c  = 'TN' , 
            Address__c= 'Test',Furnishing_Status__c = 'Furnished',Rent__c = 15000,Country__c= 'India'
        );
        INSERT property;
        
        // Create test lease agreement
        Lease_Agreement__c leaseAgreement = new Lease_Agreement__c(Property__c = property.Id);
        INSERT leaseAgreement;
    }
    
    static void testSendPdfEmail() {
        // Retrieve the test lease agreement
        Lease_Agreement__c leaseAgreement = [SELECT Id FROM Lease_Agreement__c LIMIT 1];
        
        // Create a sample PDF content (base64 encoded string)
        String samplePdfContent = EncodingUtil.base64Encode(Blob.valueOf('Sample PDF Content'));
        
        // Start test context
        Test.startTest();
        
        // Call the method
        LeaseAgreementController.sendPdfEmail(leaseAgreement.Id, samplePdfContent);
        
        // Stop test context
        Test.stopTest();
        
    }
    
    @isTest
    static void testSendPdfEmailInvalidRecordId() {
        // Create a sample PDF content (base64 encoded string)
        String samplePdfContent = EncodingUtil.base64Encode(Blob.valueOf('Sample PDF Content'));
        
        // Start test context
        Test.startTest();
        
        // Call the method with an invalid record ID
        try {
            LeaseAgreementController.sendPdfEmail('invalidId', samplePdfContent);
            System.assert(false, 'Method should have thrown an exception.');
        } catch (exception e) {
            system.debug('Email Send Failed');
        }
        
        // Stop test context
        Test.stopTest();
    }
}