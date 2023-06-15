/***
 * @author IAICHE Imed Eddine
 * @date 21/07/2021
 * @description Trigger pour l'objet ContractPersonRole__c
 */
trigger ContractPersonRoleTrigger on ContractPersonRole__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.Run(new ContractPersonRoleTriggerHandler());
}