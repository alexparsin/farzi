import { LightningElement, wire, track, api } from 'lwc';
import loadObjects from '@salesforce/apex/HerokuAdminUIController.retrieveObjects';
import loadConfig from '@salesforce/apex/HerokuAdminUIController.getSyncConfig';
import generateSyncConfig from '@salesforce/apex/HerokuAdminUIController.generateSyncConfig';
import getFields from '@salesforce/apex/HerokuAdminUIController.getFields';
import checkSyntax from '@salesforce/apex/HerokuAdminUIController.checkSyntax';
import saveMetadata from '@salesforce/apex/HerokuAdminUIController.saveMetadata';
import getSummaryHerokuRecs from '@salesforce/apex/HerokuAdminUIController.getSummaryHerokuRecs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";

const columns = [
    { label: 'Object Name', fieldName: 'objectName', sortable: true },
    { label: 'Type', fieldName: 'objectType', sortable: true},
    { label: 'API Name', fieldName: 'objectAPIName', sortable: true}    
];
const fieldColumns = [
    { label: 'Field Name', fieldName: 'fieldName', sortable: true },
    { label: 'Type', fieldName: 'fieldType', sortable: true},
    { label: 'API Name', fieldName: 'fieldAPIName', sortable: true}    
];
const filterCreatedDateFilters = [
    { label: 'equals', value: '=' },
    { label: 'not equal to', value: '!=' },
    { label: 'less than', value: '<' },
    { label: 'greater than', value: '>' },
    { label: 'less or equal', value: '<=' },
    { label: 'greater or equal', value: '>=' }
];
   
    const columnshe = [   
    { label: 'Name', fieldName: 'HerokuName', type: 'url',sortable: true ,
    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank'} },
    { label: 'Status', fieldName: 'Status__c',sortable: true }, 
 {
        label: "CreatedDate",
        sortable: true ,
        fieldName: "CreatedDate",
        type: "date-local",
        typeAttributes:{
            month: "2-digit",
            day: "2-digit"
        }
    }
];


export default class HerokuAdminUI extends NavigationMixin(LightningElement) {
    @track today = new Date().toISOString().slice(0,10);
    @track recordsToDisplay = [];
    @track rtdRecordCount;
    @track isPagination = false;
    @track RTDData = [];

    @track herokuColumnss=columnshe;
    @track error;
    @track objList;
    @track relatedObjList;
    @track selectedObjList;
    //@track allObjevctSelectUI = [];
    @track allObjectsTable = false;
    @track parentObjectsTable = false;
    @track selectedObjectsTable = false;
    @track fieldList ;
    columns = columns;
    fieldColumns = fieldColumns;
    savebutton=false;
    allObjects = false;
    homeSummary = true;
    nextbutton=true;
    value = '';
    value1 = '';
    @track allObjectNextVisibility = true;
    @track selectedObjectNextVisibility = false;
    @track sortBy;
    @track sortDirection;
    @track objFlowModal = false;
    @track fieldsTableVisible = false;
    @track flowSelectPage = false;
    @track schedulingPage = false;
    @track filteringPage = false;
    @track progressIndicator = 'Step0';
    @track createdDateFilterValue;
    @track recordTypeValue;
    @track selectedRecordTypes = [];
    @track recordTypeOptions;
    @track selectedValue;
    @track schselectedValue;
    @track schselectedValueTime;
    @track schselectedValueDate;
    @track nextNavigationVisibility = true;
    @track backNavigationVisibility = true;
    @track cancelNavigationVisibility = false;
    @track SaveNavigationVisibility=true;

    @track regularFlowSelected = false;
    @track childrenFlowSelected = false;

    @track selectObject;
    @track selectedFields;

    @track initialRecordsObject;
    @track initialRecordsFields;

    @track syntaxCheckVisibility = true;
    @track resetVisibility = false;
    @track filterCondition;

    @track isShowModal = false;
    @track selectedRowObjName='';
    @track summaryList;
     
    @track sortBy;
    @track sortRelatedBy;
    @track sortDirection;
    @track sortRelatedDirection;
    
    @track configurationRequired = true;
    
    @track componentIsLoading = true;

   
    handleSortObjectData(event) {       
        console.log('handleSortObjectData');
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortObjectData(event.detail.fieldName, event.detail.sortDirection,this.objList,'ObjectData');
    }

   
    handleSortRelatedObjectData(event) {       
        console.log('handleSortRelatedObjectData');
        this.sortRelatedBy = event.detail.fieldName;       
        this.sortRelatedDirection = event.detail.sortDirection;       
        this.sortObjectData(event.detail.fieldName, event.detail.sortDirection,this.relatedObjList,'ObjectData');
    }
    handleSortFieldsData(event) {       
        console.log('handleSortFieldsData');
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortObjectData(event.detail.fieldName, event.detail.sortDirection,this.fieldList,'ObjectFields');
    }
    handleSortHerokuData(event) {       
        console.log('handleSortHerokuData');
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortObjectData(event.detail.fieldName, event.detail.sortDirection,this.recordsToDisplay,'herokuData');
    }
 
    sortObjectData(fieldname, direction,sourceData,sourceType) {
        console.log('sortObjectData');
        
        let parseData = JSON.parse(JSON.stringify(sourceData));
       
        let keyValue = (a) => {
            return a[fieldname];
        };
 
       let isReverse = direction === 'asc' ? 1: -1;
 
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        
        if(sourceType=='herokuData'){
           this.recordsToDisplay = parseData;
        }else if(sourceType=='ObjectData'){
            this.objList = parseData;
        }else if(sourceType=='ObjectFields'){
            this.fieldList = parseData;
        }
    }

    get createdDateFilterOptions() {
        return [
            { label: 'equals', value: '=' },
            { label: 'not equal', value: '!=' },
            { label: 'less than', value: '<' },
            { label: 'greater than', value: '>' },
            { label: 'less or equal', value: '<=' },
            { label: 'greater or equal', value: '>=' }
        ];
    }
    get options() {
        return [
            { label: 'Week', value: 'weekly' },
            { label: 'Month', value: 'monthly' }
        ];
    }
    get options1() {
        return [
            { label: 'Mon', value: 'Monday' },
            { label: 'Tues', value: 'Tuesday' },
            { label: 'Wed', value: 'Wednesday' },
            { label: 'Thur', value: 'Thursday' },
            { label: 'Fri', value: 'Friday' },
            { label: 'Sat', value: 'Saturday' },
            { label: 'Sun', value: 'Sunday' }
        ];
    }
    
    handlePaginatorChange(event) {
        console.log('handlePaginatorChange');
            this.recordsToDisplay = event.detail;
            if (this.recordsToDisplay[0])
                this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
        }

    handleChangeWeek(event){
        console.log('handleChangeWeek');
        var sele=event.detail.value;  
         this.selectedValue = sele.join(",");    
        console.log('days----'+this.selectedValue);
    }
    handleschChange(event){
        console.log('handleschChange');
        this.schselectedValue = event.target.value;
        console.log('runs by'+this.schselectedValue);
    }
    handleschChangetime(event){
        console.log('handleschChangetime');
        this.schselectedValueTime = event.target.value;
        console.log('schselectedValueTime by'+this.schselectedValueTime);
    }
        handleschChangeDate(event){
        this.schselectedValueDate = event.target.value;
        console.log('schselectedValueTime by'+this.schselectedValueTime);
    }

    connectedCallback() {
        console.log('connectedCallback');
        this.componentIsLoading = true;
        this.getHerokuSummary();
        loadConfig()
            .then((result) => {
                if(result){
                    console.log('result');
                    console.log(result);
                    this.configurationRequired = false;
                }
                this.componentIsLoading = false;
            })
            .catch((error) => {
                this.componentIsLoading = false;
                console.error('loadConfig error');
                console.error(error);
                this.error = error;
            });
    }

    resetAction() {
        console.log('resetAction');
       this.filterCondition='';  
    }

    hideModalBox() {  
        console.log('hideModalBox');
        this.isShowModal = false;
        this.selectedRowObjName='';  
    }

    getHerokuSummary(){  
        console.log('getHerokuSummary');     
         getSummaryHerokuRecs()
            .then((result) => {
                console.log('watch resule;;;',result);
                //this.summaryList=result;
                //var summaryResult=result;
                                    let tempRecs = [];
                    result.forEach( ( record ) => {
                        let tempRec = Object.assign( {}, record );  
                        tempRec.HerokuName = '/' + tempRec.Id;
                        // tempRec.CreatedDate = $A.localizationService.formatDate(tempRec.CreatedDate, "MMMM DD YYYY, hh:mm:ss a");
                        tempRecs.push( tempRec );
                        
                    });
                    this.summaryList = tempRecs;

                       this.RTDData = tempRecs;
                this.rtdRecordCount = tempRecs.length;
                console.log('watch data:::::::',tempRecs);
                if (this.RTDData.length > 0) {
                    this.isPagination = true;
                    this.template.querySelector("c-paginator");
                }
            this.template.querySelector("c-paginator").updateDataPostFetch(this.RTDData);
                /*         summaryResult.forEach(function(temp, Index) {
                             console.log('enterd ',temp);
                                if (temp.Id != null) {
                                    temp.herokuHyperlink = '/lightning/r/Configuration_Heroku__c/' + temp.Id + '/view';
                                }
                                if (temp.Name != null) {
                                    temp.herokuName = temp.Name;
                                }
                                if (temp.Name != null) {
                                    temp.herokuStatus = temp.Name;                                   
                                }    
    
                            });
                            this.summaryList = summaryResult;
                            console.log('watch finaldata',this.summaryList); */
            })
            .catch((error) => {                
                this.error = error;
                this.fieldList = undefined;
            });


    }

    showModalBox(event) {
        console.log('showModalBox'); 
            let element = this.selectedObjList.find(ele  => ele.objectAPIName === event.target.dataset.id);
        console.log('syntaxCheckAction element --->',element);    
        this.filterCondition =element.ObjWhereCondition;
        this.selectedRowObjName='';  
        this.isShowModal = true;
     let eventData = event.target.dataset.id;
     this.selectedRowObjName=eventData;
    console.log('Watch eventData Obj Name --->',this.selectedRowObjName);
    }
    
    filterUpdate(event){
        console.log('filterUpdate'); 
        this.filterCondition = event.target.value;
        console.log('filterCondition 1: '+this.filterCondition);
        this.syntaxCheckVisibility = false;
  /*      this.filterCondition = event.target.value;
        console.log('Test 2: '+this.filterCondition);
        console.log('Test 3: '+this.selectObject[0].objectAPIName);
        if(this.filterCondition != null)
            this.syntaxCheckVisibility = false;
        else if(this.filterCondition == null || this.filterCondition == '')
            this.syntaxCheckVisibility = true;  */
    }
   
    syntaxCheckAction(){
        console.log('syntaxCheckAction');
        console.log('syntaxCheckAction element 0--->',this.selectedRowObjName);
         console.log('syntaxCheckAction element 0filterCondition--->',this.filterCondition);
       if(this.filterCondition!='' && this.filterCondition!=null){
        checkSyntax({ ObjectAPIName: this.selectedRowObjName, filter: this.filterCondition })
            .then((result) => {
                if(result == true){ 
                    console.log('syntaxCheckAction element 1--->',this.selectedObjList);
                    console.log('syntaxCheckAction element 2--->',this.selectedRowObjName);                  
                    let element = this.selectedObjList.find(ele  => ele.objectAPIName === this.selectedRowObjName);
                    console.log('syntaxCheckAction element --->',element);
                    element.ObjWhereCondition = this.filterCondition;
                    console.log('syntaxCheckAction ObjWhereCondition --->',element);
                    const eventSuccess = new ShowToastEvent({
                        title: 'Success!',
                        variant: 'success',
                        message:
                            'The filters you are using are correct.',
                    });
                    this.dispatchEvent(eventSuccess);
                      this.isShowModal = false;
                      this.selectedRowObjName='';  
                }
                else if(result == false){
                    const eventError = new ShowToastEvent({
                        title: 'Error!',
                        variant: 'error',
                        message:
                            'The filters you are using are incorrect....',
                    });
                    this.dispatchEvent(eventError);
                }
            })
            .catch((error) => {
                console.log('syntaxCheckAction element error--->',error);
                const eventError = new ShowToastEvent({
                    title: 'Error!',
                    variant: 'error',
                    message:
                        'The filters you are using are incorrect.8',
                });
                this.dispatchEvent(eventError);
                this.error = error;
                this.fieldList = undefined;
            });
    }else{
         this.isShowModal = false;
           let element = this.selectedObjList.find(ele  => ele.objectAPIName === this.selectedRowObjName);
                    console.log('syntaxCheckAction element --->',element);
                    element.ObjWhereCondition = this.filterCondition;
               const eventSuccess = new ShowToastEvent({
                        title: 'Success!',
                        variant: 'success',
                        message:
                            'The filters removed',
                    });
                    this.dispatchEvent(eventSuccess);
        }
    }

    saveMetadataAction(){
        console.log('saveMetadataAction');
        var dateValidated = false;
        let startsAt = this.template.querySelector(".startsAt");
        let dateCmp = this.template.querySelector(".dateCls");
        if(!startsAt) {
            startsAt.setCustomValidity("Starts At Field is Required");
        }
        startsAt.reportValidity();
        
        var today = new Date();
        today = today.toISOString().slice(0,10);
        if(dateCmp.value < today){
            dateCmp.setCustomValidity('Date should always more than today');
        } else {
            dateValidated = true;
            dateCmp.setCustomValidity('');
        }
        dateCmp.reportValidity();

        if(dateValidated===true){
        saveMetadata({myWrap : this.selectedObjList, Scheduleby : this.schselectedValue, ScheduleTime : this.schselectedValueTime, ScheduleAt : this.selectedValue, SelectedDate : this.schselectedValueDate})
        .then(result=>{
            if(result){
        //alert(JSON.stringify(result));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Job details saved!',
                                variant: 'success'
                            })
                        );

                                    this[NavigationMixin.Navigate]({
                    type: "standard__recordPage",
                    attributes: {
                    objectApiName: "Configuration_Heroku__c",
                    actionName: "view",
                    recordId: result
                    }
                });
               this.homeBarAction();
            this.getHerokuSummary();
        }
        })
        .catch((error) => {
            let errors = '';
            error.body.pageErrors.forEach(err => {
                errors += err.message;
            });
            console.log(errors);
            const eventError = new ShowToastEvent({
                title: 'Error!',
                variant: 'error',
                message: errors,
            });
            this.dispatchEvent(eventError);
            this.error = error;
            this.fieldList = undefined;
        });
    }
    }

    prepareData(){
        console.log('prepareData');
            var fetchedDataSA = JSON.parse(JSON.stringify(this.selectedObjList));
        //var fetchedDataSA = this.selectedObjList;
        console.log('fetchedDataSA=====',fetchedDataSA);
        fetchedDataSA.forEach(function(temp, Index) {
            if (temp.objectAPIName != null) {
                temp.objectAPIName = temp.objectAPIName;
            }
            if (temp.objectName != null) {
                temp.objectName = temp.objectName;
            }
            if (temp.objectType != null) {
                temp.objectType = temp.objectType;
            }
            temp.ObjWhereCondition = '';
            temp.selectedObjFieldsList = '';
            temp.IsObjWhereCondition = false;

        });
        this.selectedObjList = fetchedDataSA;
    }

    parentObjectRowSelection(event){

    }

    allObjectRowSelection(event) {
        console.log('allObjectRowSelection');
        console.log('Log entered here: ',JSON.stringify(event.detail.selectedRows));
        var selectedRows=event.detail.selectedRows;
         console.log('Watch Lenght:::',selectedRows.length);
         if(!this.childrenFlowSelected){
             this.nextNavigationVisibility = false;
         }
          this.selectedObjList=selectedRows.slice(0, 5);
         if(selectedRows.length>5){
             this.showToastMessage('You can only select 5 objects for archieving.','Error');
         }
           var el = this.template.querySelector('lightning-datatable');
            selectedRows=el.selectedRows=el.selectedRows.slice(0,5);
            //selectedRows.pop();
            console.log('Watch final select:::',this.selectedObjList)
            this.prepareData();
       
     /*   var selectedRows=event.detail.selectedRows;
        this.selectedObjList = selectedRows;
        this.prepareData();
        this.allObjevctSelectUI = selectedRows;
       if(selectedRows.length>5)
        {
            this.nextNavigationVisibility = false;
            this.selectedObjList = selectedRows.slice(0, 5);
             this.prepareData();
            var el = this.template.querySelector('lightning-datatable');
            selectedRows=el.selectedRows=el.selectedRows.slice(0,5);
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'Error',
                message: 'You can only select 5 objects for archieving.'
            });
            this.dispatchEvent(event);
            event.preventDefault();
        } 
        else if(selectedRows.length == 1){
            this.nextNavigationVisibility = false;
        }
        else if(selectedRows.length == 0){
            this.nextNavigationVisibility = true;
        }  */
        
    }

    showToastMessage(displayMessage,displayMode){
        console.log('showToastMessage');
         const event = new ShowToastEvent({
                title: 'Error',
                variant: displayMode,
                message: displayMessage
            });
            this.dispatchEvent(event);
    }

    selectedObjectRowSelection(event) {
        console.log('selectedObjectRowSelection');
        this.fieldList='';
       //var el = this.template.querySelector('lightning-datatable');
        //selectedRows=el.selectedRows=el.selectedRows.slice(0,0);
        console.log('Watch obje selectedRows;;::',event.target.dataset.id);
        this.selectObject = event.target.dataset.id;      
         console.log('Watch obje Name::',this.selectObject);      

        getFields({ selectedObject: event.target.dataset.id })
            .then((result) => {
                this.fieldList = result.fieldDetails;
                this.initialRecordsFields = result.fieldDetails;
                let options = [];
                for(let key in result.recordTypes){
                    options.push({ label: key, value: result.recordTypes[key] });
                }
                this.recordTypeOptions = options;
                this.error = undefined;
                console.log('Object API  this.fieldList1---- '+ this.fieldList);
            })
            .catch((error) => {
                this.error = error;
                this.fieldList = undefined;
            });
    }

    selectedFieldRowSelection(event) {
        console.log('selectedFieldRowSelection');
        var selectedRows=event.detail.selectedRows;
        this.selectedFields = selectedRows;
        console.log('selected fields: '+this.selectedFields)
        if(selectedRows.length>30)
        {
            this.selectedFields = selectedRows.slice(0, 30);
             this.prepareData();
            var el = this.template.querySelector('lightning-datatable');
            selectedRows=el.selectedRows=el.selectedRows.slice(0,30);
            this.showToastMessage('You can only select 30 fields for each object.','Error');
        }
    var seletedFields = JSON.parse(JSON.stringify(this.selectedFields));  
    var seletedfieldsList=[];     
        console.log('fetchedDataSA=====',seletedFields);
        seletedFields.forEach(function(temp, Index) {
            if (temp.fieldAPIName != null) {
               seletedfieldsList.push(temp.fieldAPIName);
            }            
        });
        console.log('seletedfieldsList List::',seletedfieldsList);
        //console.log('seletedfieldsList List 2::',seletedfieldsList.join(","));        
        let element = this.selectedObjList.find(ele  => ele.objectAPIName === this.selectObject);       
        element.selectedObjFieldsList = seletedfieldsList.join(",");
        console.log('syntaxCheckAction element --->',element);
       // this.selectedFields = seletedFields;
    }
    
    allObjectNextAction(){
        console.log('allObjectNextAction');
        this.allObjectsTable = false;
        this.selectedObjectsTable = true;
        this.schedulingPage = false;
        this.progressIndicator = 'Step2';
        getFields({ selectedObject: 'Account' })
            .then((result) => {
                this.fieldList = result.fieldDetails;
                //this.recordTypeData = result.recordTypes;
                let options = [];
                for(let key in result.recordTypes){
                    console.log('Label be: '+key);
                    console.log('Value be: '+result.recordTypes[key]);
                    
                    options.push({ label: key, value: result.recordTypes[key] });
                }
                this.recordTypeOptions = options;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.fieldList = undefined;
            });
    }

    nextNavigationAction(){
        console.log('nextNavigationAction');
        if(this.progressIndicator == 'Step1'){
            console.log('This is step-1');
            this.allObjectsTable = false;
            this.parentObjectsTable = false;
            this.selectedObjectsTable = true;
            this.progressIndicator = 'Step2';
            this.nextNavigationVisibility = false;
            this.backNavigationVisibility = false;
        }
        else if(this.progressIndicator == 'Step2'){
            console.log('This is step-2');
            this.selectedObjectsTable = false;
            this.filteringPage = true;
            this.progressIndicator = 'Step3';
            this.nextNavigationVisibility = false;
            this.backNavigationVisibility = false;
        }
        else if(this.progressIndicator == 'Step3'){
            console.log('This is step-3');
            this.filteringPage = false;
            this.schedulingPage = true;
            this.progressIndicator = 'Step4';
            this.nextNavigationVisibility = true;
            this.backNavigationVisibility = false;
             this.SaveNavigationVisibility=false;
               this.savebutton=true;
               this.nextbutton=false;
        }
        else if(this.progressIndicator == 'Step4'){
            console.log('This is step-4');
            this.nextNavigationVisibility = true;
            this.backNavigationVisibility = false;
            this.SaveNavigationVisibility=false;
            this.nextbutton=false;
            this.savebutton=true;
        }
    }

    backNavigationAction(){
        console.log('backNavigationAction');
        this.nextbutton=true;
        this.savebutton=false;
        this.nextNavigationVisibility=false;
        if(this.progressIndicator == 'Step1'){
            //this.nextNavigationVisibility = true;
            this.backNavigationVisibility = true;
            this.SaveNavigationVisibility=true;
        }
        else if(this.progressIndicator == 'Step2'){
            this.allObjectsTable = true;
            this.selectedObjectsTable = false;
            this.progressIndicator = 'Step1';
           // this.nextNavigationVisibility = true;
            this.backNavigationVisibility = true;
            this.SaveNavigationVisibility=true;
        }
        else if(this.progressIndicator == 'Step3'){
            this.filteringPage = false;
            this.selectedObjectsTable = true;
            this.progressIndicator = 'Step2';
            //this.nextNavigationVisibility = true;
            this.backNavigationVisibility = false;
            this.SaveNavigationVisibility=false;
        }
        else if(this.progressIndicator == 'Step4'){
            this.filteringPage = true;
            this.schedulingPage = false;
            this.progressIndicator = 'Step3';
            //this.nextNavigationVisibility = true;
            this.backNavigationVisibility = false;
        }
    }

    homeBarAction(){
        console.log('homeBarAction');
        this.allObjectsTable = false;
            this.selectedObjectsTable = false;
            this.filteringPage = false;
            this.schedulingPage = false;
            this.progressIndicator = 'Step1';
            this.nextNavigationVisibility = false;
            this.backNavigationVisibility = false;
            this.allObjects = false;
            this.homeSummary = true;
    }

    allObjectSideBarAction(){
        console.log('allObjectSideBarAction');
        this.homeSummary = false;
        this.allObjects = true;
        this.flowSelectPage = true;
            this.allObjectsTable = false;
            this.parentObjectsTable = false;
            this.selectedObjectsTable = false;
            this.filteringPage = false;
            this.schedulingPage = false;
            this.progressIndicator = 'Step0';
            this.nextNavigationVisibility = true;
            this.backNavigationVisibility = true;
            
             this.selectedStep = 'Step0';
             this.SaveNavigationVisibility=true;
             this.cancelNavigationVisibility=true;
             this.savebutton=false;
             this.nextbutton=true;
             this.fieldList='';
             
    }

    selectRegularFLow(){
        this.componentIsLoading = true;
        console.log('selectRegularFLow');
        this.regularFlowSelected = true;
        this.childrenFlowSelected = false;
        this.allObjectsTable = true;
        this.parentObjectsTable = false;
        this.activateStepOne();
    }
    
    selectChildrenFlow(){
        this.componentIsLoading = true;
        console.log('selectChildrenFlow');
        this.regularFlowSelected = false;
        this.childrenFlowSelected = true;
        this.allObjectsTable = false;
        this.parentObjectsTable = true;
        this.activateStepOne();
    }

    activateStepOne(){
        console.log('activateStepOne');
        this.progressIndicator = 'Step1';
        this.flowSelectPage = false;
        this.backNavigationVisibility = false;
    
        loadObjects()
            .then((result) => {
                this.componentIsLoading = false;
                this.objList = result;
                this.initialRecordsObject = result;
                this.allObjevctSelectUI = [];
            })
            .catch((error) => {
                this.componentIsLoading = false;
                this.error = error;
                this.fieldList = undefined;
            });
    }

    handleCreatedDateFilterChange(event) {
        console.log('handleCreatedDateFilterChange');
        this.createdDateFilterValue = event.detail.value;
        console.log("Selected Value be: "+this.createdDateFilterValue);
    }

    recordTypeChange(event) {
        console.log('recordTypeChange');
        this.recordTypeValue = event.detail.value;
        if(!this.selectedRecordTypes.includes(event.detail.value)){
            this.selectedRecordTypes.push(event.detail.value);
        }
    }

    handleRemove_RecordType(event){
        console.log('handleRemove_RecordType');
        const valueRemoved = event.target.name;
        this.selectedRecordTypes.splice(this.selectedRecordTypes.indexOf(valueRemoved), 1); 
    }

    selectStep0() {
        console.log('this is Step0');
        this.selectedStep = 'Step0';
    }

    selectStep1() {
        console.log('this is Step1');
        this.selectedStep = 'Step1';
    }
 
    selectStep2() {
        console.log('this is Step2');
        this.selectedStep = 'Step2';
    }
 
    selectStep3() {
        console.log('this is Step3');
        this.selectedStep = 'Step3';
    }
 
    selectStep4() {
        console.log('this is Step4');
        this.selectedStep = 'Step4';
    }

    handleSearch_Object(event) {
        console.log('handleSearch_Object');
        const searchKey = event.target.value.toLowerCase();
 
        if (searchKey) {
            this.objList = this.initialRecordsObject;
 
            if (this.objList) {
                let searchRecords = [];
 
                for (let record of this.objList) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        let strVal = String(val);
 
                        if (strVal) {
 
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                this.objList = searchRecords;
            }
        } else {
            this.objList = this.initialRecordsObject;
        }
    }

    handleSearch_Field(event) {
        console.log('handleSearch_Field');
        const searchKey = event.target.value.toLowerCase();
        this.selectedFields = this.selectedFields;
        if (searchKey) {
            this.fieldList = this.initialRecordsFields;
 
            if (this.fieldList) {
                let searchRecords = [];
 
                for (let record of this.fieldList) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        console.log('val is ' + val);
                        let strVal = String(val);
 
                        if (strVal) {
 
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                this.fieldList = searchRecords;
            }
        } else {
            this.fieldList = this.initialRecordsFields;
        }
    }

    refreshFields(){
        console.log('refreshFields');
        getFields({ selectedObject: this.selectObject[0].objectAPIName })
            .then((result) => {
                this.fieldList = result.fieldDetails;
                this.initialRecordsFields = result.fieldDetails;
                let options = [];
                for(let key in result.recordTypes){
                    options.push({ label: key, value: result.recordTypes[key] });
                }
                this.recordTypeOptions = options;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.fieldList = undefined;
            });
    }

    refreshObjects(){
        console.log('refreshObjects');
        loadObjects()
            .then((result) => {
                this.objList = result;
                this.allObjectsTable = true;
                this.initialRecordsObject = result;
            })
            .catch((error) => {
                this.error = error;
                this.fieldList = undefined;
            });
    }

    handleRowAction(event) {
        console.log('handleRowAction');
        const row = event.detail.row;
        row.expandable = !row.expandable;
    }

    generateConfiguration(){
        console.log('generateConfiguration');
        this.componentIsLoading = true;
        generateSyncConfig()
            .then((result) => {
                this.componentIsLoading = false;
                this.configurationRequired = false;
            })
            .catch((error) => {
                console.error(error);
                this.componentIsLoading = false;
                this.error = error;
            });
    }

}