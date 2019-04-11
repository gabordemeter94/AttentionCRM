/**
 * @author     	Attention CRM Consulting Kft. (lenovo_ce@attentioncrm.hu) 
 * @since		2018-10-04
 */
public abstract class EMEACloneRelatedRecordBase implements Database.Batchable<SObject> {

	/*Queueable instance, helps to invoke next cloneController if there any*/
	protected EMEAClonedRelatedRecordsQueuable cloneQueue = null;

	/*Key: soruceObjectId clone related list other this object, Value: targetObjectId attach related list under this object*/
	protected Map<Id, Id> parentToClone = null;
	protected Set<Id> recordIds = null;

	protected Integer batchSize = 10;

	public void setBatchSize(Integer size) {
		this.batchSize = size;
	}

	/**
	 * @description filter batch just query these specific records under from parent
	 * @param recordIds  - specific record Ids
	 */
	public void addSpecificRecordIds(Set<Id> recordIds) {
		this.recordIds = recordIds;
	}

	public virtual void cloneRelatedRecords(Map<Id, Id> cloneMap, EMEAClonedRelatedRecordsQueuable cloneQueue) {
		this.parentToClone = cloneMap;
		this.cloneQueue = cloneQueue;
		Database.executeBatch(this, this.batchSize);
	}



	protected abstract Database.QueryLocator start(Database.BatchableContext context);

	protected abstract void execute(Database.BatchableContext context, List<SObject> scope);

	public virtual void finish(Database.BatchableContext context) {
		if (this.cloneQueue != null) {
			this.cloneQueue.cloneNextRelatedList();
		}
	}
}