/***
 * @author Attali David
 * @date 03/07/2019
 * @description Trigger pour l'objet produit d'opportunité (OpportunityLineItem)
*/
trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new OpportunityLineItemHandler());
}