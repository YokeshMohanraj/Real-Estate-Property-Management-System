/***************************************************************************************************************************************
* Name           :  MaintenanceRequestTriggerHandler
* Description    :  used as the Handler class for the Maintenance Request Trigger
* Test class     :  MaintenanceRequestTriggerHandlerTest
* @author        :  Yokesh Mohanraj
* @date          :  03/22/2025
****************************************************************************************************************************************/

public class MaintenanceRequestTriggerHandler {
    public static void BeforeInsert(List<Maintenance_Request__c> newRequests){
        // Query vendors and their current workload
        List<Vendor__c> vendors = [SELECT Id, Name, (SELECT Id FROM Maintenance_Requests__r) FROM Vendor__c];
        
        // Create a list of wrapper objects to store vendor IDs and their workloads
        List<VendorWorkload> vendorWorkloads = new List<VendorWorkload>();
        for (Vendor__c vendor : vendors) {
            vendorWorkloads.add(new VendorWorkload(vendor.Id, vendor.Maintenance_Requests__r.size()));
        }
        
        vendorWorkloads.sort();
        
        // Assign maintenance requests to vendors in a round-robin fashion
        Integer vendorIndex = 0;
        for (Maintenance_Request__c request : newRequests) {
            Id selectedVendorId = vendorWorkloads[vendorIndex].vendorId;
            request.Vendor__c = selectedVendorId;
            
            // Update the workload in the wrapper object
            vendorWorkloads[vendorIndex].workload++;
            
            // Move to the next vendor
            vendorIndex++;
            if (vendorIndex >= vendorWorkloads.size()) {
                vendorIndex = 0;
            }
        }
    }
    
    // Wrapper class to store vendor IDs and their workloads
    public class VendorWorkload implements Comparable {
        public Id vendorId;
        public Integer workload;
        
        public VendorWorkload(Id vendorId, Integer workload) {
            this.vendorId = vendorId;
            this.workload = workload;
        }
        
        // Implement the compareTo method to sort by workload
        public Integer compareTo(Object other) {
            VendorWorkload otherWorkload = (VendorWorkload) other;
            return this.workload - otherWorkload.workload;
        }
    }    
}