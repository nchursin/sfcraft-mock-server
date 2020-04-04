trigger TestTrigger on Account (before insert, before update, before delete, after update, after insert, after delete, after undelete) {
    (new Test_ATrigger.TestTriggerHandler()).onTrigger();
}