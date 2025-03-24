/***************************************************************************************************************************************
* Name           :  PropertiesListViewController
* Description    :  Display the property records based on the filter inputs recieved. used in the LWC component named propertiesListView.
* Test class     :  PropertiesListViewControllerTest
* @author        :  Yokesh Mohanraj
* @date          :  03/22/2025
****************************************************************************************************************************************/

public with sharing class PropertiesListViewController {
    @AuraEnabled
    public static String getProperties(Decimal userLat, Decimal userLong,Integer distance, Integer pageSize, Integer pageNumber,Integer rentPrice,String status,String furnishedStatus){
        String jsonData;
        Integer offset = (pageNumber - 1) * pageSize;
        Integer totalRecords;
        Integer recordEnd = pageSize * pageNumber;  

        // Building the query dynamically based on the filter inputs recieved.
        String query = 'SELECT Name,Property_Location__latitude__s, Property_Location__longitude__s, Furnishing_Status__c, Rent__c, Status__c, Type__c FROM Property__c';
        List<String> conditions = new List<String>();
        if (rentPrice != null) {
            conditions.add('Rent__c <= :rentPrice');
        }
        if (furnishedStatus != null) {
            conditions.add('Furnishing_Status__c = :furnishedStatus');
        }
        if (status != null) {
            conditions.add('Status__c = :status');
        }
        //To calculate the distance between the user location and the property location
       if(distance != null){
           conditions.add('DISTANCE(Property_Location__c, GEOLOCATION(' + userLat + ', ' + userLong + '), \'km\') < ' + distance);     
        }

        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
         query += ' LIMIT 25 OFFSET : offset';

        // Execute the query and assign the data to a wrapper class
        WrapperClass objcls =  new WrapperClass();  
        objcls.properties = database.query (query);
        objcls.totalRecords = objcls.properties.size();
        objcls.pageSize = pageSize;
        objcls.pageNumber = pageNumber;
        objcls.recordStart = offset + 1;
        objcls.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        jsonData = JSON.serialize(objcls);
        return jsonData;
    }
    
    public class WrapperClass {
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}
        public List<Property__c> properties {get;set;}
    }
}