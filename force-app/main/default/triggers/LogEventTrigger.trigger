trigger LogEventTrigger on Log__e (after insert) {
	TriggerDispatcher.Run(new LogEventTriggerHandler());
}