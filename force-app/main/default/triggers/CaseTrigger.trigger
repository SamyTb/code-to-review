/***
 * @author Carlos MARQUES DOS SANTOS
 * @date 15/04/2022
 * @description Trigger pour l'objet Case
 */

trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
	TriggerDispatcher.Run(new CaseTriggerHandler());
}