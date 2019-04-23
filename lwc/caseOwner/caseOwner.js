import { LightningElement, api,track ,wire } from 'lwc';
import getAvailableOwnerList from '@salesforce/apex/ChnageOwnerController.getAvailableOwnerList';
import updateOwner from '@salesforce/apex/ChnageOwnerController.updateOwner';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';


export default class CaseOwner extends LightningElement {
    @api recordId;
    @track openmodel = false;
    @track selectedVal = '';
    
    //get available queues for Case object
    @wire(getAvailableOwnerList) ownerList;
    
    //Open modal
    openmodal() {
            this.openmodel = true;
    }
    //cloase modal
    closeModal() {
        this.openmodel = false
    } 

    //Call save method from apex
    saveMethod() {
        if(this.selectedVal!=''){
            //Calling Apex method with params
            updateOwner({
                caseID: this.recordId,
                ownerID: this.selectedVal
            })
            .then(result => {
                const evt = new ShowToastEvent({
                    title: 'Record Update',
                    message: 'Record Updated Successfully ',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                //firing refresh event
                this.dispatchEvent(new CustomEvent('recordChange'));
            })
            .catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Application Error',
                    message: 'Error received: code' + error.errorCode + ', ' + 'message ' + error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            });
            this.closeModal();
        }else{
            console.log('Please select Owner');
        }
    }

    //Handle picklist change
    handleChange(event) {
        this.selectedVal=event.detail.value;
    }
}