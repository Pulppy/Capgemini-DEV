public class ICF_SurveyDeliveryFactory {
	// SMS Delivery provider class name
	public static String ICF_SMSDELIVERY_NAME = 'ICF_SMSDelivery';
	// Email Delivery provider class name
	public static String ICF_EMAIL_DELIVERY_NAME = 'ICF_EmailDelivery';

	/*
	* Return instance of SMS delivery provider class 
	*/ 
	public static ICF_ISMSDelivery getSMSDeliveryInstance() {
		return  (ICF_ISMSDelivery) Type.forName(ICF_IOC_Mapping__c.getInstance(ICF_SMSDELIVERY_NAME).Class_Name__c).newInstance();
	} 


	/*
	* Return instance of Email delivery provider class 
	*/ 
	public static ICF_IEmailDelivery getEmailDeliveryInstance() {
		return  (ICF_IEmailDelivery) Type.forName(ICF_IOC_Mapping__c.getInstance(ICF_EMAIL_DELIVERY_NAME).Class_Name__c).newInstance();
	}

}