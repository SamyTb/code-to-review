/***
 * @author David Attali
 * @date 27/03/2020
 * @description Trigger pour l'objet OpportunityTeamMember
 */

trigger OpportunityTeamMemberTrigger on OpportunityTeamMember (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new OpportunityTeamMemberTriggerHandler());
}