import { LightningElement, api } from 'lwc';

export default class FileUploadGuestUser extends LightningElement {

    @api myRecordId;

    get encryptedToken() {
        //use apex to get
    }

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
    }
}