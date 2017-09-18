/*
* クラス名:		Wrapper Class
* クラス概要:		新入生を挿入
* @created:		2016/04/11 Ksvc Nguyen Hoang Khoi
* @modified:    
*/
public class WrapperClass {
        public Boolean checked {get;set;}
        public HocSinh__c hs {get;set;}
        public WrapperClass(HocSinh__c hs) {
            this.hs = hs;           
        }
    }