/***
 * @author Mouloud HABCHI
 * @date 23/08/2022
 * @description Trigger pour l'objet CaseComment
 */

trigger CaseCommentTrigger on CaseComment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.Run(new CaseCommentTriggerHandler());
}