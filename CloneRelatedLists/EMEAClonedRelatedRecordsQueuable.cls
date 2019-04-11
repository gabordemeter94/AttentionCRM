/**
 * @author     	Attention CRM Consulting Kft. (lenovo_ce@attentioncrm.hu) 
 * @since		2018-10-04
 * @testclass testEMEACloneRecords
 */

public class EMEAClonedRelatedRecordsQueuable implements Queueable {
	
	/*Key: soruceObjectId clone related list other this object, Value: targetObjectId attach related list under this object*/
	private Map<Id, Id> cloneMap;

	/*Containts Relatedlist Batch Classes, clone those related list*/
	private List<EMEACloneRelatedRecordBase> cloneRelatedControlles;
	private Boolean isParallel = true;

	//Constructors
	public EMEAClonedRelatedRecordsQueuable() { }

	public EMEAClonedRelatedRecordsQueuable(Map<Id, Id> cloneMap) {
		this.cloneMap = cloneMap;
		this.cloneRelatedControlles = new List<EMEACloneRelatedRecordBase>();
	}

	public EMEAClonedRelatedRecordsQueuable(Map<Id, Id> cloneMap,  List<EMEACloneRelatedRecordBase> cloneRelatedControlles) {
		this.cloneMap = cloneMap;		
		this.cloneRelatedControlles = cloneRelatedControlles;
	}

	/*Member methods*/
	private Boolean isMoreRelatedList(){
		if(this.cloneRelatedControlles.isEmpty()){
			return false;
		}
		return true;
	}

	public void cloneNextRelatedList(){
		if(this.isMoreRelatedList()){
				EMEACloneRelatedRecordBase firstRelatedList = this.cloneRelatedControlles.remove(0);
				firstRelatedList.cloneRelatedRecords(this.cloneMap, this);
			}
	}

	public void setParallelModeOff() { 
		this.isParallel = false;
	}

	public void execute(QueueableContext context) {
		if(isParallel){
			for (EMEACloneRelatedRecordBase controller : cloneRelatedControlles) {
				controller.cloneRelatedRecords(this.cloneMap, null);				
			}
		}else{
			cloneNextRelatedList();
		}
	}

	public void addAttachmentsClone(EMEABatchAttachmentCopy controller){
		this.cloneRelatedControlles.add(controller);
	}

	public void addEmailsClone(EMEABatchEmailCopy controller){
		this.cloneRelatedControlles.add(controller);
	}

	public void addCaseSerialClone(EMEABatchCaseSerialCopy controller){
		this.cloneRelatedControlles.add(controller);
	}


	

}