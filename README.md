# AttentionCRM

## CloneRelatedLists

CloneMapben kulcs source objektum ID-> value: target ID és egy listában megadjuk melyik related listáját akkarjuk változtattni

```
 System.enqueueJob(new EMEAClonedRelatedRecordsQueuable(cloneMap,
                new List<EMEACloneRelatedRecordBase>{
                        new EMEABatchEmailCopy(),
                        new EMEABatchAttachmentCopy(),
                        new EMEABatchCaseSerialCopy()
                }
        )
        );
```       
 
