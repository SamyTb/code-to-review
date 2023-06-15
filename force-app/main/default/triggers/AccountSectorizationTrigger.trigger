/***
 * @author Casassus Matthieu
 * @date 30/01/2020
 * @description Trigger pour l'objet Table de Sectorisation
 */
trigger AccountSectorizationTrigger on AccountSectorization__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new AccountSectorizationTriggerHandler());
}