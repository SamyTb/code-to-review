/***
 * @author Attali David
 * @date 28/01/2019
 * @description Trigger pour l'objet événement
 */
trigger EventTrigger on Event (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new EventTriggerHandler());
}