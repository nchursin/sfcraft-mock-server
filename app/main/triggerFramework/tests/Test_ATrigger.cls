@isTest
public class Test_ATrigger {
    private static final sObject TEST_RECORD = new Account(Name = 'Test_ATrigger');
    private static final String TEST_FIELD_NAME = 'Name';
    private static final Object TEST_FIELD_CHANGED_VALUE = 'Changed Name';

    private enum TriggerState {
        T_INSERT,
        T_UPDATE,
        T_DELETE,
        T_UNDELETE
    }

    private static final String INITIALIZE = 'initialize ';
    private static final String PREVALIDATE = 'preValidate ';
    private static final String CALCULATE = 'calculate ';
    private static final String VALIDATE = 'validate ';
    private static final String AFTER_INSERT = 'afterInsert ';
    private static final String AFTER_UPSERT = 'afterUpsert ';
    private static final String AFTER_UPDATE = 'afterUpdate ';
    private static final String VALIDATE_BEFORE_DELETE = 'validateBeforeDelete ';
    private static final String AFTER_DELETE = 'afterDelete ';
    private static final String AFTER_UNDELETE = 'afterUndelete ';

    private static final Map<TriggerState, List<String>> SEQUENCE_MAP = new Map<TriggerState, List<String>> {
        TriggerState.T_INSERT => new List<String> {
            INITIALIZE,
            PREVALIDATE,
            CALCULATE,
            VALIDATE,
            AFTER_INSERT,
            AFTER_UPSERT
        },
        TriggerState.T_UPDATE => new List<String> {
            PREVALIDATE,
            CALCULATE,
            VALIDATE,
            AFTER_UPDATE,
            AFTER_UPSERT
        },
        TriggerState.T_DELETE => new List<String> {
            VALIDATE_BEFORE_DELETE,
            AFTER_DELETE
        },
        TriggerState.T_UNDELETE => new List<String> {
            AFTER_UNDELETE
        }
    };

    private static final sObjectType TEST_SOBJECT_TYPE = TEST_RECORD.getSObjectType();
    private static final Schema.SObjectField TEST_SOBJECT_FIELD = TEST_SOBJECT_TYPE.getDescribe().fields.getMap().get(TEST_FIELD_NAME);
    private static final Object TEST_FIELD_OLD_VALUE = TEST_RECORD.get(TEST_FIELD_NAME);

    private static String triggerLog = '';
    private static List<sObject> testTriggerRecords;
    private static Boolean isFieldChangedResult = null;
    private static Boolean isFieldChangedToResult = null;
    private static Boolean isFieldChangedFromResult = null;

    @isTest
    private static void testSequenceInTrigger() {
        insert TEST_RECORD;
        assertSequence(TriggerState.T_INSERT);
        
        update TEST_RECORD;
        assertSequence(TriggerState.T_UPDATE);
        
        delete TEST_RECORD;
        assertSequence(TriggerState.T_DELETE);
        
        undelete TEST_RECORD;
        assertSequence(TriggerState.T_UNDELETE);
    }

    @isTest
    private static void testTriggerRecords() {
        insert TEST_RECORD;
        System.assertEquals(TEST_RECORD.Id, testTriggerRecords[0].Id, 'Trigger records first element id is not equal to expected');
        testTriggerRecords = null;
        delete TEST_RECORD;
        System.assertEquals(TEST_RECORD.Id, testTriggerRecords[0].Id, 'Trigger records first element id is not equal to expected');
    }

    @isTest
    private static void testIsFieldChanged() {
        insert TEST_RECORD;
        assertIsChangedResult(true, TriggerState.T_INSERT);
        
        update TEST_RECORD;
        assertIsChangedResult(false, TriggerState.T_UPDATE);
        
        TEST_RECORD.put(TEST_FIELD_NAME, TEST_FIELD_CHANGED_VALUE);
        update TEST_RECORD;
        assertIsChangedResult(true, TriggerState.T_UPDATE);

        delete TEST_RECORD;
        undelete TEST_RECORD;
        assertIsChangedResult(true, TriggerState.T_UNDELETE);
    }

    @isTest
    private static void testIsFieldChangedTo() {
        insert TEST_RECORD;
        assertIsChangedToResult(false, TriggerState.T_INSERT);

        SObject cloned = TEST_RECORD.clone(false);
        cloned.put(TEST_FIELD_NAME, TEST_FIELD_CHANGED_VALUE);
        insert cloned;
        assertIsChangedToResult(true, TriggerState.T_INSERT);
    }

    @isTest
    private static void testIsFieldChangedFrom() {
        insert TEST_RECORD;
        assertIsFieldChangedFromResult(false, TriggerState.T_INSERT);

        TEST_RECORD.put(TEST_FIELD_NAME, TEST_FIELD_CHANGED_VALUE);
        update TEST_RECORD;
        assertIsChangedResult(true, TriggerState.T_UPDATE);
    }

    @isTest
    private static void testDisableAll() {
        ATrigger.disableAll();
        insert TEST_RECORD;
        System.assertEquals('', triggerLog, 'Sequence should be empty when all triggers disabled');
        ATrigger.enableAll();
        triggerLog = '';
        sObject cloned = TEST_RECORD.clone(false);
        insert cloned;
        assertSequence(TriggerState.T_INSERT);
    }

    @isTest
    private static void testDisableGranular() {
        ATrigger.disable(TEST_SOBJECT_TYPE, TriggerOperation.BEFORE_INSERT);
        insert TEST_RECORD;
        String logToCheck = AFTER_INSERT + AFTER_UPSERT;
        System.assertEquals(logToCheck, triggerLog, 'Sequence should be only for after insert');
        ATrigger.enableAll();
        triggerLog = '';
        sObject cloned = TEST_RECORD.clone(false);
        insert cloned;
        assertSequence(TriggerState.T_INSERT);
    }

    private static String getSequence(TriggerState state) {
        return String.join(SEQUENCE_MAP.get(state), '');
    }

    private static void assertSequence(TriggerState state) {
        String logToTest = getSequence(state);
        System.assertEquals(logToTest, triggerLog, 'Sequence is wrong for ' + state.name() + ' trigger.');
        triggerLog = '';
    }

    private static void assertIsChangedResult(Boolean expected, TriggerState state) {
        String message = 'isFieldChanged should return ' + expected + ' in ' + state.name() + ' context';
        if (TriggerState.T_INSERT != state || TriggerState.T_UPDATE != state) {
            String isFieldChangedStr = expected ? ' ' : ' not ';
            message += ' if field is' + isFieldChangedStr + 'changed';
        }
        System.assertEquals(expected, isFieldChangedResult, message);
        isFieldChangedResult = null;
    }

    private static void assertIsChangedToResult(Boolean expected, TriggerState state) {
        String message = 'isFieldChangedTo should return ' + expected + ' in ' + state.name() + ' context';
        String isFieldChangedStr = expected ? ' ' : ' not ';
        message += ' if field is' + isFieldChangedStr + 'changed';
        message += expected ? ' and' : ' or';
        message += ' new value is' + isFieldChangedStr + 'equal to ' + TEST_FIELD_CHANGED_VALUE;
        System.assertEquals(expected, isFieldChangedToResult, message);
        isFieldChangedToResult = null;
    }

    private static void assertIsFieldChangedFromResult(Boolean expected, TriggerState state) {
        String message = 'isFieldChangedFrom should return ' + expected + ' in ' + state.name() + ' context';
        String isFieldChangedStr = expected ? ' ' : ' not ';
        message += ' if field is' + isFieldChangedStr + 'changed';
        message += expected ? ' and' : ' or';
        message += ' old value was' + isFieldChangedStr + 'equal to ' + TEST_FIELD_OLD_VALUE;
        System.assertEquals(expected, isFieldChangedFromResult, message);
        isFieldChangedFromResult = null;
    }

    public class TestTriggerHandler extends ATrigger {
        protected override void initialize(List<sObject> records) {
            testTriggerRecords = records;
            triggerLog += INITIALIZE;
        }

        protected override void calculate(List<sObject> records) {
            triggerLog += CALCULATE;
            isFieldChangedResult = isFieldChanged(records[0], TEST_SOBJECT_FIELD);
            isFieldChangedToResult = isFieldChangedTo(records[0], TEST_SOBJECT_FIELD, TEST_FIELD_CHANGED_VALUE);
            isFieldChangedFromResult = isFieldChangedFrom(records[0], TEST_SOBJECT_FIELD, TEST_FIELD_OLD_VALUE);
        }

        protected override void validate(List<sObject> records) {
            triggerLog += VALIDATE;
        }

        protected override void preValidate(List<sObject> records) {
            triggerLog += PREVALIDATE;
        }

        protected override void afterInsert(List<sObject> records) {
            triggerLog += AFTER_INSERT;
        }

        protected override void afterUpsert(List<sObject> records) {
            triggerLog += AFTER_UPSERT;
        }

        protected override void afterUpdate(List<sObject> records) {
            triggerLog += AFTER_UPDATE;
        }

        protected override void validateBeforeDelete(List<sObject> records) {
            triggerLog += VALIDATE_BEFORE_DELETE;
        }

        protected override void afterDelete(List<sObject> records) {
            testTriggerRecords = records;
            triggerLog += AFTER_DELETE;
        }

        protected override void afterUndelete(List<sObject> records) {
            triggerLog += AFTER_UNDELETE;
            isFieldChangedResult = isFieldChanged(records[0], TEST_SOBJECT_FIELD);
        }
    }
}
