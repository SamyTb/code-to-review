/***
 * @author Casassus Matthieu
 * @date 02/08/2019
 * @description Trigger pour l'objet Opportunity
 */

trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerDispatcher.Run(new OpportunityTriggerHandler());
}