public abstract inherited sharing class ATrigger {

    protected List<sObject> triggerRecords {
        get {
            if (null == this.triggerRecords) {
                if (Trigger.isDelete) {
                    this.triggerRecords = Trigger.old;
                } else {
                    this.triggerRecords = Trigger.new;
                }
            }
            return this.triggerRecords;
        }
        set;
    }

    private Map<Id, SObject> oldMap {
        get {
            if (null == oldMap) {
                oldmap = Trigger.isInsert ? new Map<Id, sObject>() : Trigger.oldMap;
            }
            return oldMap;
        }
        set;
    }

    private static Map<Schema.SObjectType, Set<TriggerOperation>> triggerDisabledMap = 
        new Map<Schema.SObjectType, Set<TriggerOperation>>();

    public static void disable(Schema.SObjectType sobjType, TriggerOperation triggerOper) {
        if (!triggerDisabledMap.containsKey(sobjType)) {
            triggerDisabledMap.put(sobjType, new Set<TriggerOperation>());
        }
        triggerDisabledMap.get(sobjType).add(triggerOper);
    }

    public static void disableAll(Schema.SObjectType sobjType) {
        for (TriggerOperation operation : TriggerOperation.values()) {
            disable(sobjType, operation);
        }
    }

    public static void disableAll() {
        isDisabledAll = true;
    }

    public static void enableAll() {
        isDisabledAll = false;
        triggerDisabledMap.clear();
    }

    private static Boolean isDisabledAll = false;

    public void onTrigger() {
        if (isDisabled(Trigger.operationType)) {
            return;
        }
    
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                this.initialize(this.triggerRecords);
                this.preValidate(this.triggerRecords);
                this.calculate(this.triggerRecords);
                this.validate(this.triggerRecords);
            }
            when AFTER_INSERT {
                this.afterInsert(this.triggerRecords);
                this.afterUpsert(this.triggerRecords);
            }
            when BEFORE_UPDATE {
                this.preValidate(this.triggerRecords);
                this.calculate(this.triggerRecords);
                this.validate(this.triggerRecords);
            }
            when AFTER_UPDATE {
                this.afterUpdate(this.triggerRecords);
                this.afterUpsert(this.triggerRecords);
            }
            when BEFORE_DELETE {
                this.validateBeforeDelete(this.triggerRecords);
            }
            when AFTER_DELETE {
                this.afterDelete(this.triggerRecords);
            }
            when AFTER_UNDELETE {
                this.afterUndelete(this.triggerRecords);
            }
            when else {
                // not trigger context, or unknown event
            }
        }
    }

    protected virtual void initialize (List<sObject> records) {}

    protected virtual void preValidate (List<sObject> records) {}

    protected virtual void calculate (List<sObject> records) {}

    protected virtual void validate (List<sObject> records) {}

    protected virtual void afterInsert (List<sObject> records) {}

    protected virtual void afterUpsert (List<sObject> records) {}

    protected virtual void afterUpdate (List<sObject> records) {}

    protected virtual void validateBeforeDelete (List<sObject> records) {}

    protected virtual void afterDelete (List<sObject> records) {}

    protected virtual void afterUndelete (List<sObject> records) {}
    
    protected Schema.SObjectType getSObjectType () {
        return this.triggerRecords.getSObjectType();
    }

    protected Set<TriggerOperation> getDisabledOperations(Schema.SObjectType sobjType) {
        Set<TriggerOperation> result = triggerDisabledMap.get(sobjType);
        if (null == result) {
            result = new Set<TriggerOperation>();
        }
        return result;
    }

    protected Boolean isDisabled(TriggerOperation operation) {
        if (isDisabledAll) {
            return true;
        }
        Schema.SObjectType sobjType = this.getSObjectType();
        Set<TriggerOperation> disabledOperations = getDisabledOperations(sobjType);
        return disabledOperations.contains(Trigger.operationType);
    }

    protected Boolean isFieldChanged(sObject record, Schema.SObjectField field) {
        if (Trigger.isInsert || Trigger.isUndelete) {
            return true;
        } else {
            Object value = record.get(field);
            Object oldValue = getOldFieldValue(record, field);
            return !value.equals(oldValue);
        }
    }

    protected Boolean isFieldChangedTo(sObject record, Schema.SObjectField field, Object checkValue) {
        Object newValue = record.get(field);
        return isFieldChanged(record, field) && checkValue.equals(newValue);
    }

    protected Boolean isFieldChangedFrom(sObject record, Schema.SObjectField field, Object checkValue) {
        if (Trigger.isInsert) {
            // for insert trigger this means changing value from null
            return null == checkValue;
        }
        Object oldValue = getOldFieldValue(record, field);
        return isFieldChanged(record, field) && checkValue.equals(oldValue);
    }

    protected sObject getOldRecord(sObject record) {
        return oldMap.get(record.Id);
    }

    protected Object getOldFieldValue(sObject record, Schema.SObjectField field) {
        SObject oldRecord = getOldRecord(record);
        Object result = null;
        if (null != oldRecord) {
            result = oldRecord.get(field);
        }
        return result;
    }
}
