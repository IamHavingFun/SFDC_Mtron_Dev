/**************************************************************************************** 
  * File Name   : IF_BaseLogVO 
  * Description : IF_BaseLogVO
  * Author      : ldb3100
  * Modification Log
  * =============================================================== 
  * Ver  Date        Author          Modification
  * ===============================================================
    1.0  2020.03.09  ldb3100         Create 
****************************************************************************************/
public with sharing class IF_BaseLogVO {
    public IF_LOG__c log;
    public Blob sndJsonBlob;
    public Blob rcvJsonBlob;
    
    public IF_BaseLogVO(IF_LOG__c log, String sndJsonBlob, String rcvJsonBlob){
        this.log = log;
        
        if(sndJsonBlob == null){
            sndJsonBlob = '';
        }
        if(rcvJsonBlob == null){
            rcvJsonBlob = '';
        }
        this.sndJsonBlob = Blob.valueof(sndJsonBlob);
        this.rcvJsonBlob = Blob.valueof(rcvJsonBlob);
    }
}