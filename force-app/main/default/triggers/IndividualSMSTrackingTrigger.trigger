/**
 * Created by IAICHE Imed Eddine on 03/04/2020.
 */

trigger IndividualSMSTrackingTrigger on IndividualSMSTracking__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new IndividualSMSTrackingTriggerHandler());
}