/**
 * This class clones the Case-Serial use  transform case
 *
 * @author Attention CRM Consulting Kft. [FL] (lenovo_ce@attentioncrm.hu)
 * @since  2018-10-22
 * @update 2018-10-22 extends from EMEACloneRelatedRecordBase
 *
 * @testclass testEMEACloneRecords
 */
public class EMEABatchCaseSerialCopy extends EMEACloneRelatedRecordBase {

    private final List<String> requestedFields = new List<String>{
            'Id',
//            'OwnerId',
            'Case__c',
            'Case__r.RecordType.Name',
            'Serial_Number__c',
            'Master_Serial_Number__c',
            //'Replacement_Machine_Serial_Number__c',
            //'Replacement_Serial_Number__c',
            //'Proposed_Solution__c',
            'RecordTypeId'
    };

    public EMEABatchCaseSerialCopy() {

    }

    /**
    * @description constructor to clone SN with specific ids
    * @param recordIds  - just clone these records from source case
    */
    public EMEABatchCaseSerialCopy(Set<Id> recordIds) {
        this.recordIds = recordIds;
    }


    public override Database.QueryLocator start(Database.BatchableContext context) {


        Set<Id> relatedParentIds = this.parentToClone.keySet();

        String query = 'SELECT ';
        query += String.join(requestedFields, ', ');
        query += ' FROM Serial_Number__c';
        query += ' WHERE Case__c IN :relatedParentIds' ;

        if (this.recordIds != null) {
            query += ' AND Id IN :recordIds';
        }

        if (Test.isRunningTest()) {
            query += ' Limit :batchSize';
        }

        System.debug('query = ' + query);
        return Database.getQueryLocator(query);
    }


    public override void execute(Database.BatchableContext context, List<SObject> scope) {
        List<Serial_Number__c> snsToInsert = new List<Serial_Number__c>();

        for (SObject item : scope) {
            Serial_Number__c clonedFromSn = (Serial_Number__c) item;
            snsToInsert.add(createCaseSerialFromParent(clonedFromSn));
        }

        if (snsToInsert.size() > 0) {
            try {
                insert snsToInsert;
            } catch (Exception e) {
                System.debug(e.getStackTraceString());
            }
        }

    }

    /**
    * @description custom logic how to clone the case, it can be diffrent by teams
    * @param clonedFromSn the record which is the source
    * @return cloned SN
    */
    private Serial_Number__c createCaseSerialFromParent(Serial_Number__c clonedFromSn) {
        Serial_Number__c newSn = new Serial_Number__c(
                Serial_Number__c = clonedFromSn.Serial_Number__c,
                Master_Serial_Number__c = clonedFromSn.Master_Serial_Number__c,
                Case__c = this.parentToClone.get(clonedFromSn.Case__c),
                RecordTypeId = EMEASerialNumberHandler.snMainRtType
        );

        if (clonedFromSn.Case__r.RecordType.Name == 'EAST Service Delivery Management') {
            newSn.RecordTypeId = EMEASerialNumberHandler.snSDMRtType;
        }

        System.debug(newSn);
        return newSn;
    }
}