/**
 * This class clones the emails of given cases, 
 * with the power of magic and the {@code Database.Batchable} interface.
 *
 * @author Attention CRM Consulting Kft. [FL] (lenovo_ce@attentioncrm.hu)
 * @since  2017-02-27
 * @update 2018-10-04 extends from EMEACloneRelatedRecordBase
 *
 * @testclass testEMEACloneRecords
 */

public class EMEABatchEmailCopy extends EMEACloneRelatedRecordBase {

	public EMEABatchEmailCopy() { }



	public override Database.QueryLocator start(Database.BatchableContext bc) {
		String emailQuery = 'SELECT ';

		Set<Id> parents = parentToClone.keySet();
		Map<String, Schema.SObjectField> emailMessageSchemaFieldMap = Schema.SObjectType.EmailMessage.fields.getMap();

		for (String fieldName : emailMessageSchemaFieldMap.keySet()) {
			emailQuery += (fieldName + ', ');
		}

		// During test, we need to limit the query results to fit in one batch, because of test limitations.
		emailQuery = emailQuery.substringBeforeLast(',') + ' FROM EmailMessage WHERE ParentId IN :parents';		
		
		if(this.recordIds != null){
			emailQuery += ' AND Id IN :recordIds';
		}
		
		 if(Test.isRunningTest()){
			emailQuery += ' Limit :batchSize';
		 }

		

		return Database.getQueryLocator(emailQuery);
	}

	public override void execute(Database.BatchableContext bc, List<sObject> scope) {

		String fixedHTMLPreText = '=====\nThe HTML formating has beed removed from this email due to it exceeding the character limit!\n=====\n\n';
		String fixedPlainPreText = '=====\nThe text was shortened due to character limits!\n=====\n\n';

		List<EmailMessage> emailsToInsert = new List<EmailMessage> ();
		for (sObject sObj : scope) {
			// Temporary parent email message
			EmailMessage temp_p = (EmailMessage) sObj;
			// Temporary cloned email message
			EmailMessage temp_c = temp_p.clone(false, true, false, false);

			// When the HTML text is longer than 32K character, it must be cut.
			// In this case we copy the plain text version of the email.
			// It is usually under 32K characters. If not, we cut it at 32K chars.
			if (temp_c.HtmlBody != null && temp_c.HtmlBody.length() >= 32000) {
				temp_c.HtmlBody = fixedHTMLPreText +
				(temp_c.TextBody.length() >= (32000 - fixedHTMLPreText.length()) ?
				 temp_c.TextBody.subString(0, 32000 - fixedHTMLPreText.length() - 1) :
				 temp_c.TextBody);
			}

			if (temp_c.TextBody != null && temp_c.TextBody.length() >= 32000) {
				temp_c.TextBody = fixedPlainPreText + temp_c.TextBody.subString(0, 32000 - fixedHTMLPreText.length() - 1);
			}

			temp_c.ParentId = parentToClone.get(temp_p.ParentId);
			emailsToInsert.add(temp_c);
		}

		if (!emailsToInsert.isEmpty()) {
			insert emailsToInsert;
		}

	}

}