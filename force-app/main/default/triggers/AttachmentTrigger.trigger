/** Author: IAICHE Imed Eddine
    Date: 03/02/2020
    Feature: SCX-1315
 */
trigger AttachmentTrigger on Attachment (before insert, after insert, before update, after update, before delete){
    TriggerDispatcher.Run(new AttachmentTriggerHandler());
}