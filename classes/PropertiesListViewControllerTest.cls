@isTest
public class PropertiesListViewControllerTest {
    @testSetup
    static void setup() {
        // Create test properties
        List<Property__c> properties = new List<Property__c>();
        for (Integer i = 0; i < 10; i++) {
            properties.add(new Property__c(
                Name = 'Test Property' , Description__c = 'Test Record' ,Status__c = 'Occupied' ,Furnishing_Status__c = 'Furnished', Rent__c = 15000,
                Type__c = 'Residential',Postal_Code__c = '603203',City__c= 'Chennai' , State__c  = 'TN' , Address__c= 'Test',Country__c= 'India'
            ));
        }
        INSERT properties;
    }
    
    @isTest
    static void testGetProperties() {
        // Positive test case
        Test.startTest();
        String result = PropertiesListViewController.getProperties(37.7749, 122.4194, 10, 5, 1, 1500, 'Available', 'Furnished');
        Test.stopTest();
        
        // Deserialize the result
        PropertiesListViewController.WrapperClass wrapper = (PropertiesListViewController.WrapperClass) JSON.deserialize(result, PropertiesListViewController.WrapperClass.class);
        
        // Verify the results
        System.assertEquals(5, wrapper.pageSize, 'Page size should be 5');
        System.assertEquals(1, wrapper.pageNumber, 'Page number should be 1');
        System.assertEquals(1, wrapper.recordStart, 'Record start should be 1');
    }
    
    @isTest
    static void testGetPropertiesNoResults() {
        // Negative test case
        Test.startTest();
        String result = PropertiesListViewController.getProperties(37.7749, -122.4194, 10, 5, 1, 500, 'Unavailable', 'Nonexistent');
        Test.stopTest();
        
        // Deserialize the result
        PropertiesListViewController.WrapperClass wrapper = (PropertiesListViewController.WrapperClass) JSON.deserialize(result, PropertiesListViewController.WrapperClass.class);
        
        // Verify the results
        System.assertEquals(5, wrapper.pageSize, 'Page size should be 5');
        System.assertEquals(1, wrapper.pageNumber, 'Page number should be 1');
        System.assertEquals(0, wrapper.totalRecords, 'Total records should be 0');
        System.assertEquals(1, wrapper.recordStart, 'Record start should be 1');
        System.assertEquals(0, wrapper.properties.size(), 'Properties size should be 0');
    }
}