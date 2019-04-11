public class EMEABatchAttachmentCopy extends EMEACloneRelatedRecordBase {
    
	public EMEABatchAttachmentCopy(){}
	
	
	/**
	 * In the constructor we receive the parent case id -> cloned case id mapping.
	 * 
	 * @param
	 *	mapping of the parent->child releationship for transfered cases
	 */
 
	public override Database.QueryLocator start(Database.BatchableContext bc) {

		Set<Id> parentIdSet = parentToClone.keySet();
		Map<String, Schema.SObjectField> attachmentSchemaFieldMap = Schema.SObjectType.Attachment.fields.getMap();
		
		String attachmentQuery = 'SELECT ';
		for(String fieldName : attachmentSchemaFieldMap.keySet()) {
			attachmentQuery += (fieldName + ', ');
		}
		attachmentQuery = attachmentQuery.substringBeforeLast(',') + ' FROM Attachment WHERE ParentId IN :parentIdSet';
		
		if(this.recordIds != null){
			attachmentQuery += ' AND Id IN :recordIds';
		}
		
		 if(Test.isRunningTest()){
			attachmentQuery += ' Limit :batchSize';
		 }
		
		return Database.getQueryLocator(attachmentQuery);
	}
	
	
	public  override void execute(Database.BatchableContext bc, List<sObject> scope) {
		List<Attachment> attachmentsToInsert = new List<Attachment>();
		for(sObject sObj: scope) {
			// Temporary parent email message
			Attachment temp_p = (Attachment) sObj;
			// Temporary cloned email message
			Attachment temp_c = temp_p.clone(false, true, false, false);
			
			temp_c.ParentId = parentToClone.get(temp_p.ParentId);
			attachmentsToInsert.add(temp_c);
		}
		
		if(attachmentsToInsert.size() > 0) {
			insert attachmentsToInsert;
		}
	}
    

    
}