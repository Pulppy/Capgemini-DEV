public class SCRUMEipVO {

    public class CustomerVO {
        public String accountId { get; set; }
        public String accountName { get; set; }
        public String RecordId { get; set; }
        public String HKID { get; set; }
        public String ChineseName { get; set; }
        public String EnglishName { get; set; }
        public String Gender { get; set; }
        public String DateOfBirth { get; set; }
        public String CustomerId {get;set;}
        public String MaritalStatus {get;set;}
        public AddressVO Address {get;set;}
        public policyVO Policy {get;set;}
        //public String BlacklistBankruptcy { get; set; }
        //public String BlacklistAml { get; set; }
        //public String BlacklistCourtCase { get; set; }
        //public String BlacklistFraud { get; set; }
        //public String BlacklistSeriousComplaint { get; set; }
        public String OccupationClassCd { get; set; }
        public String CustomerValue {get;set;}
        public String totalRecordCount { get; set; }
    }
    
    public class AddressVO {
        public String TypeCd {get;set;}
        public String Line1 {get;set;}
        public String Line2 {get;set;}
        public String Line3 {get;set;}
        public String Line4 {get;set;}
        public String CityNm {get;set;}
        public String Mobile { get; set; }
        public String OfficePhone { get; set; }
        public String HomePhone { get; set; }
        public String Email { get; set; }
        public String ExtLine1 {get;set;}
        public String ExtLine2 {get;set;}
        public String ExtLine3 {get;set;}
        public String ExtLine4 {get;set;}
    }
    
    public class ClusterPolicyVO {
        public String policyNo { get; set; }
        public String policyId { get; set; }
        public Decimal accountValue { get; set; }
        public Decimal bonusRate { get; set; }
        public String linkedPolicyNo { get; set; }
        public String linkedPolicyId { get; set; }
    }
    
    public class policyVO {
        public String CustomerId {get;set;}
        public String FraudIND { get; set; }
        public List<String> BankruptyIND { get; set; }
        public String Section { get; set; }
    }
    
    public class CommunicationVO {
        public String policyNo {get; set;}
        public String userId {get; set;}
        //public String userName {get; set;}
        public String createDate {get; set;}
        public String assessmentDetail {get; set;}
        public String section {get; set;}
        public String totalRecordCount { get; set; }
    }
        
    // Add other value objects
}