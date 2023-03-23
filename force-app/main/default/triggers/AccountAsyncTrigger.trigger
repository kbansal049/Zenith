trigger AccountAsyncTrigger on AccountChangeEvent (after insert) {
    new AccountAsyncTriggerHandler().run();
}