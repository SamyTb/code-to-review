/***
 * @author Montano Glenn
 * @date 29/05/2019
 * @description User Trigger
 */
trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.Run(new UserTriggerHandler());
}