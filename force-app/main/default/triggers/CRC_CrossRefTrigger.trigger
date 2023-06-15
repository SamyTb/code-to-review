/***
 * @author Said MORJAN
 * @date   09/08/2021
 * @description Trigger pour CRC_CrossRef__c 
*/
         /**
        *@author        : SMO
        *@date          : 2021/09/08    
        *@description   : Trigger of Cross Ref Object 
        *@param         : 
        *@return        : liste CRC_CrossRef__c to delete
    */
trigger CRC_CrossRefTrigger on CRC_CrossRef__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new CRC_CrossRefTriggerHandler());
}