/***
 * @project eCommerce 
 * @author AVN
 * @date 22/02/2022
 * @description Trigger pour l'objet DossierPM
 */

trigger DossierPMTrigger on ECOM_FolderPM__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerDispatcher.Run(new DossierPMTriggerHandler());
}