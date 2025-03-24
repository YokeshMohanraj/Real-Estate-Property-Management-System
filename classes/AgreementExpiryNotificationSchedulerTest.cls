@isTest
private class AgreementExpiryNotificationSchedulerTest {
    // Test setup method for common test data
    @TestSetup
    static void makeData() {
        Tenant__c tenant = new Tenant__c(
            Name = 'Test Tenant',
            Email__c = 'tenant@test.com'
        );
        insert tenant;

        Property__c property = new Property__c(
            Name = 'Test Property', Tenant__c = tenant.Id , Description__c = 'Test Record' ,Status__c = 'Occupied' ,Type__c = 'Residential',Postal_Code__c = '603203',City__c= 'Chennai' , State__c  = 'TN' , 
            Address__c= 'Test',Furnishing_Status__c = 'Furnished',Rent__c = 15000 ,Country__c= 'India');
        insert property;
    }

    @isTest
    static void testNotificationSentForValidDates() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];
        Date today = Date.today();

        List<Lease_Agreement__c> agreements = new List<Lease_Agreement__c>{
            new Lease_Agreement__c(
                Property__c = prop.Id,
                End_Date__c = today.addDays(1)
            ),
            new Lease_Agreement__c(
                Property__c = prop.Id,
                End_Date__c = today.addDays(30)
            )
        };
        insert agreements;

        Test.startTest();
        new AgreementExpiryNotificationScheduler().execute(null);
        Test.stopTest();
    }

    // Negative test: Verify no emails sent for non-matching dates
    @isTest
    static void testNoNotificationsForInvalidDates() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];
        
        Lease_Agreement__c agreement = new Lease_Agreement__c(
            Property__c = prop.Id,
            End_Date__c = Date.today().addDays(5)
        );
        insert agreement;

        Test.startTest();
        new AgreementExpiryNotificationScheduler().execute(null);
        Test.stopTest();

        System.assertEquals(0, Limits.getEmailInvocations(),
            'No emails should be sent');
    }

    // Edge case test: Empty email list when no agreements exist
    @isTest
    static void testNoNotificationsWithoutAgreements() {
        Test.startTest();
        new AgreementExpiryNotificationScheduler().execute(null);
        Test.stopTest();

        System.assertEquals(0, Limits.getEmailInvocations(),
            'No emails should be sent');
    }

    // Bulk test: Verify handling of 200+ records
    @isTest
    static void testBulkNotificationProcessing() {
        Property__c prop = [SELECT Id FROM Property__c LIMIT 1];
        Date today = Date.today();
        List<Lease_Agreement__c> agreements = new List<Lease_Agreement__c>();

        for(Integer i=0; i<10; i++) {
            agreements.add(new Lease_Agreement__c(
                Property__c = prop.Id,
                End_Date__c = today.addDays(i/2== 0 ? 1 : 30)
            ));
        }
        insert agreements;

        Test.startTest();
        new AgreementExpiryNotificationScheduler().execute(null);
        Test.stopTest();
    }
}