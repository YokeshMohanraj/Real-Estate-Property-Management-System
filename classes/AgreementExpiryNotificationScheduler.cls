/***************************************************************************************************************************************
* Name           :  AgreementExpiryNotificationScheduler
* Description    :  Send an automated email 1 month and 1 day before the agreement end date to tenant.
* Test class     :  AgreementExpiryNotificationSchedulerTest
* @author        :  Yokesh Mohanraj
* @date          :  03/22/2025
****************************************************************************************************************************************/

public class AgreementExpiryNotificationScheduler implements Schedulable{
    //This method would be executed when the scheduler is run
    public void execute(SchedulableContext sc){
        sendExpiryNotifications();
    }

    public void sendExpiryNotifications(){
        //Getting the date one month before and one day before
        Date oneMonthBefore = Date.today().addDays(30);
        Date oneDayBefore = Date.today().addDays(1);
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        if(oneMonthBefore != null && oneDayBefore != null){
            for (Lease_Agreement__c agreement : [SELECT Id, Property__r.Tenant__r.Email__c,  End_Date__c 
                                                 FROM Lease_Agreement__c 
                                                 WHERE  End_Date__c = :oneMonthBefore OR  End_Date__c = :oneDayBefore]){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String> {agreement.Property__r.Tenant__r.Email__c});
            email.setSubject('Lease Agreement Expiry Notification');
            email.setPlainTextBody('Your lease agreement is expiring soon. Please contact us for renewal.');
            emails.add(email);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}