/**
 * Created by IAICHE Imed eddine on 20/05/2020.
 */

trigger et4ae5_IndividualEmailResultTrigger on et4ae5__IndividualEmailResult__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new IndividualEmailResultTriggerHandler()); 
}