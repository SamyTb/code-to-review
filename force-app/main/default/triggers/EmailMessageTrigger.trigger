/**
 * Created by IAICHE IMED EDDINE on 25/07/2022.
 */

trigger EmailMessageTrigger on EmailMessage (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new EmailMessageTriggerHandler());
}