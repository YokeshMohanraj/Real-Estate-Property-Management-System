import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const fields = ['Property__c.Property_Location__Latitude__s', 'Property__c.Property_Location__Longitude__s'];

export default class PropertyLocation extends LightningElement {
    @api recordId;
    @track mapMarkers = [];
    @track error;

    @wire(getRecord, { recordId: "$recordId", fields })
    getPropertyDetails({ error, data }) {
        if (data) {
            if (data.fields.Property_Location__Latitude__s.value && data.fields.Property_Location__Longitude__s.value) {
                //Populating the latitude and Longitude on the Array to display on the map
                this.mapMarkers = [{
                    location: {
                        Latitude: data.fields.Property_Location__Latitude__s.value,
                        Longitude: data.fields.Property_Location__Longitude__s.value
                    },
                }
                ];
            }
        }
        else if (error) {
            console.error('Error loading map data:', JSON.stringify(this.error));
        }

    }
}