/***
 * @author AVN
 * @date 04/05/2022
 * @description Trigger pour l'objet contract warning (alerte de gestion)
 */
trigger ContractWarningTrigger on ContractWarning__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.Run(new ContractWarningTriggerHandler());
}