public abstract inherited sharing class ATrigger {
    protected List<sObject> triggerRecords = null;

    public void onTrigger() {
        if (Trigger.isDelete) {
            if (Trigger.isBefore) {
                this.validateBeforeDelete(this.triggerRecords);
            } else {
                this.afterDelete(this.triggerRecords);
            }
        } else if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                this.initialize(this.triggerRecords);
            }
            this.preValidate(this.triggerRecords);
            this.calculate(this.triggerRecords);
            this.validate(this.triggerRecords);
        } else if (Trigger.isUndelete) {
            this.afterUndelete(this.triggerRecords);
        } else {
            if (Trigger.isInsert) {
                this.afterInsert(this.triggerRecords);
            }
            if (Trigger.isUpdate) {
                this.afterUpdate(this.triggerRecords);
            }
            this.afterUpsert(this.triggerRecords);
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
}
