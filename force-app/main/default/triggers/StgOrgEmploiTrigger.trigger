/***
 * @author Montano Glenn
 * @date 21/02/2019
 * @description Trigger de l'objet StgOrgComEmploi__c
 */
trigger StgOrgEmploiTrigger on StgOrgEmploi__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new StgOrgEmploiTriggerHandler());
}