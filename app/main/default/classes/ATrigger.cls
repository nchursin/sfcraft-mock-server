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

    private Map<Id, SObject> oldMap;

    public void onTrigger() {
        this.oldMap = Trigger.oldMap;
        
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

    protected Boolean isFieldChanged(sObject record, Schema.SObjectField field) {
        if (Trigger.isInsert || Trigger.isUndelete) {
            return true;
        } else {
            SObject oldRecord = oldMap.get(record.Id);
            Object value = record.get(field);
            Object oldValue = oldRecord.get(field);
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
        SObject oldRecord = oldMap.get(record.Id);
        Object oldValue = oldRecord.get(field);
        return isFieldChanged(record, field) && checkValue.equals(oldValue);
    }
}
