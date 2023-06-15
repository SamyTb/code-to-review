/***
 * @author JBBARTHELEMY
 * @date 20/01/2020
 * @description Trigger pour l'objet compte (Campaign member)
 */
trigger CampaignMemberTrigger on CampaignMember (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.Run(new CampaignMemberTriggerHandler());
}