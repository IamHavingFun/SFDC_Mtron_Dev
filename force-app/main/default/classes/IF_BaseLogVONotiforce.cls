/****************************************************************************************
  * @filename      : IF_BaseLogVONotiforce
  * @projectname   : Notiforce PD3 Unmanaged
  * @author        : i2max_H2005109 
  * @date          : 2020-07-13 오전 9:00
  * @group         : e.g)tab name
  * @description   : 
  * @reference     : 
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-07-13 오전 9:00     i2max_H2005109       Create
****************************************************************************************/
public with sharing class IF_BaseLogVONotiforce {
	public Notiforce_IF_LOG__c log;
    public Blob sndJsonBlob;
    public Blob rcvJsonBlob;
    
    public IF_BaseLogVONotiforce(Notiforce_IF_LOG__c log, String sndJsonBlob, String rcvJsonBlob){
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