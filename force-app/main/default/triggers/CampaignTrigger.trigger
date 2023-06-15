/***
 * @author Montano Glenn
 * @date 26/04/2019
 * @description Campaign trigger
 */
trigger CampaignTrigger on Campaign (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.Run(new CampaignTriggerHandler());
}