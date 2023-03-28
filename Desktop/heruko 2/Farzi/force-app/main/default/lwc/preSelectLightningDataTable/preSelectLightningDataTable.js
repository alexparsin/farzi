import { LightningElement } from 'lwc';

export default class PreSelectLightningDataTable extends LightningElement {

    // Load data via init handler first
    // then handle programmatic selection
    handleSelect() {
        const rows = ['a'];
        this.selectedRows = rows;
    }
}