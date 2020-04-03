@isTest
public class Test_ATrigger {
    // TODO: "isFieldChanged" method returns true if field is changed on update operation

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

    private static final Account TEST_RECORD = new Account(Name = 'Test_ATrigger');

    public static String triggerLog = '';

    public class TestTriggerHandler extends ATrigger {
        protected override void initialize(List<sObject> records) {
            triggerLog += INITIALIZE;
        }

        protected override void calculate(List<sObject> records) {
            triggerLog += CALCULATE;
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
            triggerLog += AFTER_DELETE;
        }

        protected override void afterUndelete(List<sObject> records) {
            triggerLog += AFTER_UNDELETE;
        }
    }

    private static String getSequence(TriggerState state) {
        return String.join(SEQUENCE_MAP.get(state), '');
    }

    private static void assertSequence(TriggerState state) {
        String logToTest = getSequence(state);
        System.assertEquals(logToTest, triggerLog, 'Sequence is wrong for ' + state.name() + ' trigger.');
        triggerLog = '';
    }

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
}
