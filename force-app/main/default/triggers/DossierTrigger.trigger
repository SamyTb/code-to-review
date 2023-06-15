/***
 * @project eCommerce 
 * @author VIAL Jeremy
 * @date 22/10/2020
 * @description Trigger pour l'objet Dossier
 */

trigger DossierTrigger on Dossier__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerDispatcher.Run(new DossierTriggerHandler());
}