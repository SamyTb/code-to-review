/***
 * @author Casassus Matthieu
 * @date 29/01/2020
 * @description Trigger pour l'objet Quote
 */
trigger QuoteTrigger on Quote (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.Run(new QuoteTriggerHandler());
}