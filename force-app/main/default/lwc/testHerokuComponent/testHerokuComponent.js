import { LightningElement, wire, track } from 'lwc';

export default class LWCFilterSearchDatatable extends LightningElement {
    @track value;
    @track options = [
        { label:'Cricket', value:'Cricket'},
        { label:'Football', value:'Football'},
        { label:'Tennis', value:'Tennis'}        
    ];
    @track allValues = [];

    handleChange(event){
        if(!this.allValues.includes(event.target.value)){
            this.allValues.push(event.target.value);
        }
    }

    handleRemove(event){
        const valueRemoved = event.target.name;
        this.allValues.splice(this.allValues.indexOf(valueRemoved), 1); 
    }

    
}