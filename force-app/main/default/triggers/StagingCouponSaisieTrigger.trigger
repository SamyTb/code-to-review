/**
 * Created by IAICHE Imed Eddine on 16/07/2020.
 */

trigger StagingCouponSaisieTrigger on STAGING_COUPONS_SAISIE__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new StagingCouponSaisieTriggerHandler());
}