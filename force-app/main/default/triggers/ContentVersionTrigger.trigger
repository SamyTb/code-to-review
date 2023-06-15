/** Author: IAICHE Imed Eddine
    Date: 28/01/2020
    Feature: SCX-1315
 */
trigger ContentVersionTrigger on ContentVersion (before insert, after insert, before update, after update) {
    TriggerDispatcher.Run(new ContentVersionTriggerHandler());    
}