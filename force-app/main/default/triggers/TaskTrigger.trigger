/*--------------------------------------------------------------------------------------------------------------------------
Author: 
Company: EI-Technologies
Description: Trigger  pour l'objet taches
Test Class: TaskTriggerHandler_TST
History
<Date>        <Authors Name>      <Brief Description of Change>
21/6/2019    Jimmy Khalil       Création
--------------------------------------------------------------------------------------------------------------------------*/
trigger TaskTrigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.Run(new TaskTriggerHandler());
}