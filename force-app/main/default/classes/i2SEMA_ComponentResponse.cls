/****************************************************************************************
  * @filename       : i2SEMA_ComponentResponse
  * @projectname    : i2sema
  * @author         : i2max_byeon.jw
  * @date           : 2020-04-07 오후 12:53
  * @group          : 
  * @group-content  : 
  * @description    : 
  * @tester         : i2SEMA_ComponentResponse_ts.cls
  * @reference      : 
  * @copyright      : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date                author              description
  * ===============================================================
    0.1     2020-04-07 오후 12:53     i2max_byeon.jw       Create
****************************************************************************************/

public virtual class i2SEMA_ComponentResponse {
    @AuraEnabled public Map<String,Object> data {get;set;}

    public i2SEMA_ComponentResponse (){
        this.data = new Map<String,Object>();
    }
    public i2SEMA_ComponentResponse setData(String key,Object value){
        this.data.put(key,value);
        return this;
    }
    public i2SEMA_ComponentResponse setData(Map<String,Object> keyValues){
        this.data.putAll(keyValues);
        return this;
    }
    public Object getData(String key){
        return this.data.get(key);
    }
}