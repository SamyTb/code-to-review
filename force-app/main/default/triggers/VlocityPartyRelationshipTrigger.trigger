/***
 * @author Casassus Matthieu
 * @date 13/08/2019
 * @description Trigger pour l'objet PartyRelationship
 */

trigger VlocityPartyRelationshipTrigger on vlocity_ins__PartyRelationship__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerDispatcher.Run(new VlocityPartyRelationshipTriggerHandler());
    
}