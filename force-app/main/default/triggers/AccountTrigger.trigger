/***
 * @author Attali David
 * @date 21/11/2018
 * @description Trigger pour l'objet compte (Account)
 */
trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Boolean hasPermission = ApexCustomPermissionSwitch_UTL.hasCustomPermission('BypassGeneratePersonNumber');
    if (Trigger.IsBefore && Trigger.IsInsert && !hasPermission) {
        Integer listSize = trigger.new.size();
        List<AccountGeneratePersonNumber__c> lstPersonNumber = new List<AccountGeneratePersonNumber__c>();
        for(Integer i = 0; i < listSize; i++){
            lstPersonNumber.add(new AccountGeneratePersonNumber__c());
        }
        insert lstPersonNumber;
        lstPersonNumber = [SELECT Name FROM AccountGeneratePersonNumber__c WHERE Id IN :lstPersonNumber];
        for(Integer i = 0; i < trigger.new.size(); i++){
            trigger.new.get(i).PersonNumber__c = lstPersonNumber.get(i).Name;
        }
    }else if(Trigger.IsBefore && Trigger.IsUpdate && !hasPermission) {
        Integer listSize = trigger.new.size();
        for(Integer i = 0; i < listSize; i++){ 
            if(Trigger.new.get(i).PersonNumber__c != Trigger.old.get(i).PersonNumber__c){
                Trigger.new.get(i).addError('Vous ne pouvez pas changer le Person Number');
            }
        }
    }
    TriggerDispatcher.Run(new AccountTriggerHandler());
}