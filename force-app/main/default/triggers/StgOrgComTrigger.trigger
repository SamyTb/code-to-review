/***
 * @author Attali David
 * @date 21/11/2018
 * @description
 */
trigger StgOrgComTrigger on StgOrgCom__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new StgOrgComTriggerHandler());
}