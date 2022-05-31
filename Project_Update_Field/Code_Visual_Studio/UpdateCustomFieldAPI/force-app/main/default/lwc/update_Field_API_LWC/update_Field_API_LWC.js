import { LightningElement,wire,track, api } from 'lwc';  
 import {refreshApex} from '@salesforce/apex';  
 import deleteCS from '@salesforce/apex/tgz_componentUpdateFieldAPI.deleteCS';  
 import updateObject from '@salesforce/apex/tgz_componentUpdateFieldAPI.updateObject';
 import getMajAutomaticallyCS from '@salesforce/apex/tgz_componentUpdateFieldAPI.getMajAutomaticallyCS';
 import getCS from '@salesforce/apex/tgz_componentUpdateFieldAPI.getCS';
 
 
 const columns=[  
  {label:'Nom Custom Setting',fieldName:'Name', type:'text', cellAttributes: {
    class: {
        fieldName: `format`
    },
    alignment: `left`
}
},  
  {label:'Objet Concerné ',fieldName:'objectName__c', type:'text'},
  {label:'Identifiant Objet',fieldName:'objectID__c', type:'text'},
  {label:'Champ Concerné',fieldName:'fieldName__c', type:'text'},
  {label:'Maj Chargement Page',fieldName:'Update_on_page_load__c'},
  {label:'Maj Toutes Les Heures',fieldName:'Update_Every_Hour__c'}
 ];  
 
 export default class DataTableInLwc extends LightningElement  {  
   res;
   res3;
   error3;
   error1;
   res2;
   error2;
   @api searchKey = '';
   @track items = [];
   @track data = [];
   @track error;
   @track data;
   isPageChanged = false;
   @track page = 1;
   @track pageSize = 5;
   @track allSelectedRows = [];
   @track totalPage = 0;
   @track startingRecord = 1;
   @track endingRecord = 0;
   @track totalRecountCount = 0;
   @track columns;
   error4;
   
 
   @wire(getCS, {searchKey: '$searchKey'})
   csList({ error, data }) {
    if (data) {
        this.processRecords(data);
        this.error = undefined;
    } else if (error) {
        this.error = error;
        this.data = undefined;
 
    }
}
 
   processRecords(data){
    this.items = data;
    this.data = this.items.slice(0,this.pageSize);
    this.totalRecountCount = data.length;
    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
    this.columns = columns;
     
}
   
   deleteRecord(){  
    var result = confirm("Vous êtes sûr de vouloir le supprimer?");
    if (result) {
        //Logic to delete the item
 
     var selectedRecords =  
      this.template.querySelector("lightning-datatable").getSelectedRows();  
      deleteCS({csList: selectedRecords})  
     .then(result=>{  
       return refreshApex(this.csList);  
     })  
     .catch(error=>{  
       alert('Cloud not delete'+JSON.stringify(error));  
     })  
    }
    else
    {
      return refreshApex(this.csList);
    }
    }
 
   majField(){  0
    var selectedRecords2 = this.template.querySelector("lightning-datatable").getSelectedRows();
    updateObject({ nameCustomSettingMAJ: selectedRecords2 })
    .then(result=>{
      if(result.length != 0)
      {
        this.res3 = result;
        this.error1 = true;
        this.error4 = false;
       
      }
      else
      {
        this.res =result;
        this.error1 = false;
        this.error4 = false;
      }
    })  
    .catch(error=>{
 
      if(this.error1 == true)
      {
        this.error1 = true;
        this.error4 = false;
      }
      else
      {
        this.error4 = error;
        this.error1 = false;
      }
     
    })  
   
 }
 
 connectedCallback() {
 
  getMajAutomaticallyCS()
  .then(result=>{  
      this.res2 = result;
      alert('Les champs sont mis à jours');
 
  })  
  .catch(error=>{  
     this.error2 = error;
     alert('Paramètre(s) invalide(s)');
  })}
 
 
  handleKeyChange( event ) {
    this.searchKey = event.target.value;
    var data = [];
    for(var i=0; i<this.items.length;i++){
        if(this.items[i]!= undefined && this.items[i].Name.includes(this.searchKey)){
            data.push(this.items[i]);
        }
    }
    this.processRecords(data);
}
 
previousHandler() {
  this.isPageChanged = true;
  if (this.page > 1) {
      this.page = this.page - 1; //decrease page by 1
      this.displayRecordPerPage(this.page);
  }
    var selectedIds = [];
    for(var i=0; i<this.allSelectedRows.length;i++){
      selectedIds.push(this.allSelectedRows[i].Id);
    }
  this.template.querySelector(
      '[data-id="table"]'
    ).selectedRows = selectedIds;
}
 
nextHandler() {
  this.isPageChanged = true;
  if((this.page<this.totalPage) && this.page !== this.totalPage){
      this.page = this.page + 1; //increase page by 1
      this.displayRecordPerPage(this.page);            
  }
    var selectedIds = [];
    for(var i=0; i<this.allSelectedRows.length;i++){
      selectedIds.push(this.allSelectedRows[i].Id);
    }
  this.template.querySelector(
      '[data-id="table"]'
    ).selectedRows = selectedIds;
}
 
displayRecordPerPage(page){
 
  this.startingRecord = ((page -1) * this.pageSize) ;
  this.endingRecord = (this.pageSize * page);
 
  this.endingRecord = (this.endingRecord > this.totalRecountCount)
                      ? this.totalRecountCount : this.endingRecord;
 
  this.data = this.items.slice(this.startingRecord, this.endingRecord);
  this.startingRecord = this.startingRecord + 1;
}
 
}  
