/***
* @author Daniel ZYSMAN
* @date 21/05/2019
* @description Trigger qui permet de synchroniser les champs customs des objets QuoteLineItem et OpportunityLineItem
*/
trigger QuoteLineItemTrigger on QuoteLineItem (after insert, after update,  before insert,before update,before delete,after delete,after undelete) {
    
  TriggerDispatcher.Run(new QuoteLineItemTriggerHandler());
     
}