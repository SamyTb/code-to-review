/**
 * Created by IAICHE Imed Eddine on 20/05/2020.
 * SCX-1698
 */

trigger OutputMailsTrigger on OutputMails__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new OutputMailsTriggerHandler());
    
}