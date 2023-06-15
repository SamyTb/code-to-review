/***
 * @author Montano Glenn
 * @date 28/02/2019
 * @description
 */
trigger StgOrgLienComUOCTrigger on StgOrgLienComUOC__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new StgOrgLienComUOCTriggerHandler());
}