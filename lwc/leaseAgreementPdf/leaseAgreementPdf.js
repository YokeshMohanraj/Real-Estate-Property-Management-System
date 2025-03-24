import { LightningElement, wire, api } from "lwc";
import jsPDFLibrary from "@salesforce/resourceUrl/jspdf";
import { loadScript } from "lightning/platformResourceLoader";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import sendPdfEmail from "@salesforce/apex/LeaseAgreementController.sendPdfEmail";

import MONTHLY_RENT_FIELD from "@salesforce/schema/Lease_Agreement__c.Agreed_Monthly_Rent__c";
import TERMS_FIELD from "@salesforce/schema/Lease_Agreement__c.Terms__c";
import START_DATE_FIELD from "@salesforce/schema/Lease_Agreement__c.Start_Date__c";
import END_DATE_FIELD from "@salesforce/schema/Lease_Agreement__c.End_Date__c";
import PROPERTY_NAME_FIELD from "@salesforce/schema/Lease_Agreement__c.Property__r.Name";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const fields = [MONTHLY_RENT_FIELD,TERMS_FIELD,START_DATE_FIELD,END_DATE_FIELD,PROPERTY_NAME_FIELD];

export default class GeneratePDFCmp extends LightningElement {
    jsPDFInitialized = false;
    @api recordId;
    agreedMonthlyRent;
    terms;
    startDate;
    endDate;
    propertyName;

    @wire(getRecord, { recordId: "$recordId", fields })
    leaseAgreementData({ data, error }) {
        if (data) {
            this.agreedMonthlyRent = getFieldValue(data, MONTHLY_RENT_FIELD);
            this.terms = getFieldValue(data, TERMS_FIELD);
            this.startDate = getFieldValue(data, START_DATE_FIELD);
            this.endDate = getFieldValue(data, END_DATE_FIELD);
            this.propertyName = getFieldValue(data, PROPERTY_NAME_FIELD);
        } else if (error) {
            this.showToast(
                "Error",
                "Something went Wrong. Contact your system admin!",
                "error"
            );
        }
    }

    renderedCallback() {
        if (!this.jsPDFInitialized) {
            this.jsPDFInitialized = true;
            loadScript(this, jsPDFLibrary)
                .then(() => {
                    console.log("jsPDF library loaded successfully");
                })
                .catch((error) => {
                    this.showToast(
                        "Error",
                        "Something went Wrong. Contact your system admin!",
                        "error"
                    );
                });
        }
    }

    generatePDF() {
        if (this.jsPDFInitialized) {
            try {
                const { jsPDF } = window.jspdf;
                const doc = new jsPDF();
                doc.text(" Lease Agreement", 70, 20);

                doc.line(60, 24, 145, 24);

                doc.setLineWidth(2);
                doc.setFontSize(14);
                doc.setFont("arial black");
                //Assigning the values to the PDF content
                doc.text("Property Name :     " + this.propertyName, 30, 60);
                doc.text("Agreed Monthly Rent :  " + this.agreedMonthlyRent, 30, 70);
                doc.text("Terms : " + this.terms, 30, 80);
                doc.text("Start Date : " + this.startDate, 30, 90);
                doc.text("End Date : " + this.endDate, 30, 100);
                doc.save("Lease Agreement.pdf");

                const pdfData = btoa(doc.output()); // Convert PDF output to Base64

                sendPdfEmail({ recordId: this.recordId, pdfContent: pdfData })
                    .then(() => {
                        this.showToast("Success", "Email sent successfully!", "success");
                    })
                    .catch((error) => {
                        this.showToast(
                            "Error",
                            "Something went Wrong. Contact your system admin!",
                            "error"
                        );
                    });
            } catch (error) {
                this.showToast(
                    "Error",
                    "Something went Wrong. Contact your system admin!",
                    "error"
                );
            }
        } else {
            this.showToast(
                "Error",
                "Something went Wrong. Contact your system admin!",
                "error"
            );
        }
    }

    showToast(titleValue, messageValue, variantValue) {
        const evt = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue,
        });
        this.dispatchEvent(evt);
    }
}
