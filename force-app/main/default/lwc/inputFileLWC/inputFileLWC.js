import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin'
import { deleteRecord } from 'lightning/uiRecordApi'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  
import getDocumentSize from '@salesforce/apex/FileUploadImprovedHelper.getDocumentSize';
const MAX_FILE_SIZE = 25000000; //10mb  

export default class InputFileLWC extends OmniscriptBaseMixin(LightningElement) {

    @api
    recordId;

    @track
    document_by_coverage;
    hasRequiredEmptyFields;
		
		checkDocSize; error;

    get acceptedFormats() {
        return ['.pdf', '.png', '.doc', '.docx', '.mpg', '.jpg', '.gif'];
    }

    connectedCallback() {
        this.recordId = JSON.parse(JSON.stringify(this.omniJsonData))?.claimId;
        this.document_by_coverage = JSON.parse(JSON.stringify(this.omniJsonData))?.document_by_coverage;
        //If result it´s not an array, convert to array
        if (!Array.isArray(this.document_by_coverage)) {
          this.document_by_coverage = [this.document_by_coverage];  
        }
        console.log(JSON.stringify(this.document_by_coverage));
        this.checkRequiredDocuments();
    }

    checkRequiredDocuments() {

      // Check required and empty documents
      this.hasRequiredEmptyFields = this.document_by_coverage.filter((document) => document.is_required && document.document_id == null);
      const data = {
        hasRequiredEmptyFields : this.hasRequiredEmptyFields.length > 0
      }
      this.omniApplyCallResp(data);
    }
		
    handleUploadFinished(event) {

        const key = event.target.dataset.key;
        const inputFile = event.detail.files[0];
				console.log(JSON.stringify(inputFile));
        const currentDocument = this.document_by_coverage.filter((document) => document.document_code === parseInt(key, 10));
        currentDocument[0].document_name = inputFile.name;
        currentDocument[0].document_id = inputFile.documentId;

        //Iterate atacched files
        const inputFiles = event.detail.files;
        console.log('Files: ' + JSON.stringify(inputFiles));
        currentDocument[0].files = [];
        const contentDocIds = [];
        const fileResultIds = [];
        inputFiles.forEach((element) => {
          currentDocument[0].files.push({"document_name":element.name, "document_id":element.documentId, "document_code":currentDocument[0].document_code});
          contentDocIds.push(element.documentId);
        });

        console.log('Files by doc: ' + JSON.stringify(currentDocument[0].files));
        
				
				try {
            
						getDocumentSize({docIds : contentDocIds})
								.then((result) => {
								//this.checkDocSize = result;
								this.error = undefined;
                console.log('result' + JSON.stringify(result));
                this.checkResult(result, currentDocument[0]);
						})
								.catch((error) => {
								this.error = error;
								this.checkDocSize = undefined;
						});
						
				} catch(e) {
						console.error('Error during file upload:',error);
				}
				
				
    }

    checkResult(result, currentDocument) {
      console.log('size ' + result);
      if(result.length > 0) {
        const evt = new ShowToastEvent({
            title: 'ERROR',
            message: 'Solo se pueden subir archivos menores o iguales a 25MB',
            variant: 'error',
        });
        this.dispatchEvent(evt);
        this.deleteFiles(result, currentDocument);
        //deleteRecord(currentDocument[0].document_id);
        //currentDocument[0].document_name = undefined;
      }else{
          const evt = new ShowToastEvent({
              title: 'SUCCESS',
              message: 'Archivos cargados correctamente!',
              variant: 'success',
          });
          this.dispatchEvent(evt);
          this.checkRequiredDocuments();
      }
    }

    deleteFiles(fileResultIds, currentDocument) {
      console.log('Datos a eliminar: ' + fileResultIds + ' ' + currentDocument);
      fileResultIds.forEach((file) => {
        console.log('file ' + file);
        deleteRecord(file);
      });

      currentDocument.files = currentDocument.files.filter((file) => !fileResultIds.includes(file.document_id));
    }
		  


    handleDelete(event) {

        const key = event.target.dataset.key;
        const fileId = event.target.dataset.docid;
        const currentDocument = this.document_by_coverage.filter((document) => document.document_code === parseInt(key, 10));
        currentDocument[0].files = currentDocument[0].files.filter((file) => file.document_id !== fileId);
        deleteRecord(fileId);
    }
}