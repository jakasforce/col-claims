import { LightningElement } from 'lwc';
import OmniscriptBlock from 'omnistudio/omniscriptBlock'
import tmpl from './editBlockLWC.html';
export default class EditBlockLWC extends OmniscriptBlock {

    /**
     * @scope private
     * @description Overwrites the native LWC render.
     * @returns {Template}
     */
    render() {
        return tmpl;
    }
}