import { LightningElement, track, wire } from 'lwc';
import getPropertiesData from '@salesforce/apex/PropertiesListViewController.getProperties';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from "lightning/uiObjectInfoApi";

const columns = [
    {
        label: 'Property Name',
        fieldName: 'Name',
        type: 'text'
    },
    {
        label: 'Rent',
        fieldName: 'Rent__c',
        type: 'Currency',
    },
    {
        label: 'Availability Status',
        fieldName: 'Status__c',
        type: 'text',
    },
    {
        label: 'Furnishing Status',
        fieldName: 'Furnishing_Status__c',
        type: 'text',
    }
];

export default class PropertiesListView extends NavigationMixin(LightningElement) {

    @track columns = columns;
    @track loader = false;
    @track error = null;
    @track pageSize = 25;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track recordEnd = 0;
    @track recordStart = 0;
    @track isPrev = false;
    @track isNext = false;
    @track properties = [];
    availibityoptions;
    furnishingoptions;

    furnishingSelectedValue;
    availabilityStatusSelectedValue;
    priceValue;
    distanceValue;
    currentUserLong;
    currentUserLat;

    handleNext() {
        if (!this.isNext) {
            this.pageNumber = this.pageNumber + 1;
            this.getProperties();
        }
    }

    handlePrevious() {
        if (!this.isPrev) {
            this.pageNumber = this.pageNumber - 1;
            this.getProperties();
        }
    }

    handleInputChange(event) {
        if (event.target.name == 'Furnishing Status') {
            this.furnishingSelectedValue = event.target.value;
        }
        if (event.target.name == 'Availabity status') {
            this.availabilityStatusSelectedValue = event.target.value;
        }
        if (event.target.name == 'price') {
            this.priceValue = event.target.value;
        }
        if (event.target.name == 'distance') {
            this.distanceValue = event.target.value;
            this.getUserLocation();
        }
    }

    //Getting the availability status picklist values dynamically. 
    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: 'Property__c.Status__c' })
    availabilitypicklistValues({ error, data }) {
        if (data) {
            this.availibityoptions = data.values;
            this.error = undefined;
        } else if (error) {
            console.log('Availibity Picklistvalues error' + JSON.stringify(error))
        }
    }
   //Getting the furnishing status picklist values dynamically.
    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: 'Property__c.Furnishing_Status__c' })
    furnishedpicklistValues({ error, data }) {
        if (data) {
            this.furnishingoptions = data.values;
            this.error = undefined;
        } else if (error) {
            console.log('Furnished Picklistvalues error' + JSON.stringify(error))
        }
    }

    onFilterButtonClick() {
        this.getProperties();
    }

    //Method to get the properties based on the filter criteria
    getProperties() {
        this.loader = true;
        getPropertiesData({
            userLat: this.currentUserLat, userLong: this.currentUserLong, distance: this.distanceValue,
            pageSize: this.pageSize,
            pageNumber: this.pageNumber, rentPrice: this.priceValue, status: this.availabilityStatusSelectedValue,
            furnishedStatus: this.furnishingSelectedValue
        })
            .then(result => {
                this.loader = false;
                if (result) {
                    var resultData = JSON.parse(result);
                    this.properties = resultData.properties;
                    this.pageNumber = resultData.pageNumber;
                    this.totalRecords = resultData.totalRecords;
                    this.recordStart = resultData.recordStart;
                    this.recordEnd = resultData.recordEnd;
                    this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                }
            })
            .catch(error => {
                this.loader = false;
                this.error = error;
            });
    }

    get isDisplayNoRecords() {
        var isDisplay = true;
        if (this.properties) {
            if (this.properties.length == 0) {
                isDisplay = true;
            } else {
                isDisplay = false;
            }
        }
        return isDisplay;
    }

    //Standard javascript method to get the current location of the user which will be used to calculate the distance from the property
    getUserLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition((position) => {
                this.currentUserLat = position.coords.latitude;
                this.currentUserLong = position.coords.longitude;
            });
        } else {
            console.log("Geolocation is not supported by this browser.");
        }
    }


    navigateToNewRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Property__c',
                actionName: 'new'
            }
        });

    }
}