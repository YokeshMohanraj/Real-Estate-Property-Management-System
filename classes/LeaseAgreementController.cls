/***************************************************************************************************************************************
* Name           :  LeaseAgreementController
* Description    :  Send an email to the tenant with the lease agreement PDF as an attachment.
* Test class     :  LeaseAgreementControllerTest
* @author        :  Yokesh Mohanraj
* @date          :  03/22/2025
****************************************************************************************************************************************/

public with sharing class LeaseAgreementController {
    @AuraEnabled
    public static void sendPdfEmail(String recordId, String pdfContent){
        try {
            Lease_Agreement__c lease = [SELECT Id, Property__r.Tenant__r.Email__c FROM Lease_Agreement__c WHERE Id = :recordId];
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('LeaseAgreement.pdf');
            attachment.setBody(EncodingUtil.base64Decode(pdfContent));
            attachment.setContentType('application/pdf');

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { lease.Property__r.Tenant__r.Email__c });
            email.setSubject('Lease Agreement PDF');
            email.setPlainTextBody('Please find the attached Lease Agreement PDF.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } catch (Exception e) {
            throw new AuraHandledException('Failed to send email: ' + e.getMessage());
        }
    }
}