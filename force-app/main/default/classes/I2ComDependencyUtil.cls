/****************************************************************************************
  * @filename      : I2ComDependencyUtil
  * @projectname   : 
  * @author        : i2max
  * @date          : 2020-06-24
  * @group         : 
  * @group-content : 
  * @description   : 
  * @tester        : I2ComDependencyUtil_ts.cls
  * @reference     : 
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-06-24         i2max          Create
****************************************************************************************/
public with sharing class I2ComDependencyUtil {

    /**
     * 콘트롤필드명을 기준으로 디펜던시되는 picklist를 option list로 구함
     *
     * @param pObjName SObject
     * @param pControllingFieldName 컨트롤 필드명
     * @param pDependentFieldName 디펜던시 필드명
     * @param labelOrApi label or Api 명 : isApi가 true인 경우에는 api명을 기입해야 한다.
     * @param isApi api 기준 여부
     * @param isSelectAll 전체 여부
     *
     * @return List<I2ComClass.Option>
     */
    public static List<I2ComClass.Option> getDependentPickListOptions(String pObjName, String pControllingFieldName, String pDependentFieldName, String labelOrApi, Boolean isApi, Boolean isSelectAll) {
        Map<String, List<String>> dependencyMap = I2ComDependencyUtil.getDependentOptions(pObjName, pControllingFieldName, pDependentFieldName, isApi);
        List<String> targetList = dependencyMap.get(labelOrApi) == null ? new List<String>() : dependencyMap.get(labelOrApi);
        List<I2ComClass.Option> targetOptions = new List<I2ComClass.Option>();

        // 전체 옵션 추가
        if(isSelectAll) targetOptions = I2ComUtil.makeInitOptions('-- 전체 --');

        for(I2ComClass.Option option : I2ComUtil.makePickListOptions(pObjName, pDependentFieldName, true)) {

            if(targetList.contains((isApi ? option.value : option.label))) {
                targetOptions.add(option);
            }
        }

        return targetOptions;
    }

    public static Map<String,List<String>> getDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName){
        return getDependentOptions(pObjName, pControllingFieldName, pDependentFieldName, false);
    }

    /**
     * 필드간 종속관계를 구함
     *
     * @param pObjName SObject명
     * @param pControllingFieldName 컨트롤 필드
     * @param pDependentFieldName 하위 필드
     * @param isApi Api 기준여부
     *
     * @return
     */
    public static Map<String, List<String>> getDependentOptions(String pObjName, String pControllingFieldName, String pDependentFieldName, Boolean isApi){
        Map<String, List<String>> objResults = new Map<String,List<String>>();
        //get the string to sobject global map
        Map<String, Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        if (!objGlobalMap.containsKey(pObjName))
            return objResults;
        //get the type being dealt with
        Schema.SObjectType pType = objGlobalMap.get(pObjName);
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        //verify field names
        if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName))
            return objResults;
        //get the control values
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        //get the dependent values
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
        //iterate through the values and get the ones valid for the controlling field name
        Bitset objBitSet = new Bitset();
        //set up the results
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){
            //get the pointer to the entry
            Schema.PicklistEntry ctrl_entry = ctrl_ple[pControllingIndex];
            //get the label
            String pControllingLabel = (isApi ? ctrl_entry.getValue() : ctrl_entry.getLabel());
            //create the entry with the label
            objResults.put(pControllingLabel,new List<String>());
        }
        //cater for null and empty
        //objResults.put('',new List<String>());
        //objResults.put(null,new List<String>());
        //check the dependent values
        for(Integer pDependentIndex=0; pDependentIndex<dep_ple.size(); pDependentIndex++){
            //get the pointer to the dependent index
            Schema.PicklistEntry dep_entry = dep_ple[pDependentIndex];
            //get the valid for
            String pEntryStructure = JSON.serialize(dep_entry);
            TPicklistEntry objDepPLE = (TPicklistEntry)JSON.deserialize(pEntryStructure, TPicklistEntry.class);
            //if valid for is empty, skip
            if (objDepPLE.validFor==null || objDepPLE.validFor==''){
                continue;
            }
            //iterate through the controlling values
            for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){
                if (objBitSet.testBit(objDepPLE.validFor,pControllingIndex)){
                    //get the label
                    String pControllingLabel = isApi ? ctrl_ple[pControllingIndex].getValue() : ctrl_ple[pControllingIndex].getLabel();
                    objResults.get(pControllingLabel).add(isApi ? objDepPLE.value : objDepPLE.label);
                }
            }
        }
        return objResults;
    }

    /*
     * @Summary: Entity to represent a json version of a picklist entry
     * so that the validFor property becomes exposed
     */
    public class TPicklistEntry {
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public TPicklistEntry(){

        }
    }

    public class Bitset {
        public Map<String, Integer> AlphaNumCharCodes {get;set;}
        public Map<String, Integer> Base64CharCodes { get; set; }
        public Bitset(){
            LoadCharCodes();
        }
        //Method loads the char codes
        private void LoadCharCodes(){
            AlphaNumCharCodes = new Map<String, Integer>{
                'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
                'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
                'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90
            };
            Base64CharCodes = new Map<String, Integer>();
            //lower case
            Set<String> pUpperCase = AlphaNumCharCodes.keySet();
            for(String pKey : pUpperCase){
                //the difference between upper case and lower case is 32
                AlphaNumCharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey)+32);
                //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
                Base64CharCodes.put(pKey,AlphaNumCharCodes.get(pKey) - 65);
                Base64CharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey) - (65) + 26);
            }
            //numerics
            for (Integer i=0; i<=9; i++){
                AlphaNumCharCodes.put(String.valueOf(i),i+48);
                //base 64 numeric starts from 52
                Base64CharCodes.put(String.valueOf(i), i + 52);
            }
        }

        public Boolean testBit(String pValidFor,Integer n){
            //the list of bytes
            List<Integer> pBytes = new List<Integer>();
            //multiply by 6 since base 64 uses 6 bits
            Integer bytesBeingUsed = (pValidFor.length() * 6)/8;
            //will be used to hold the full decimal value
            Integer pFullValue = 0;
            //must be more than 1 byte
            if (bytesBeingUsed <= 1)
                return false;
            //calculate the target bit for comparison
            Integer bit = 7 - (Math.mod(n,8));
            //calculate the octet that has in the target bit
            Integer targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed);
            //the number of bits to shift by until we find the bit to compare for true or false
            Integer shiftBits = (targetOctet * 8) + bit;
            //get the base64bytes
            for(Integer i=0;i<pValidFor.length();i++){
                //get current character value
                pBytes.add((Base64CharCodes.get((pValidFor.substring(i, i+1)))));
            }
            //calculate the full decimal value
            for (Integer i = 0; i < pBytes.size(); i++)
            {
                Integer pShiftAmount = (pBytes.size()-(i+1))*6;//used to shift by a factor 6 bits to get the value
                pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
            }
            //& is to set the same set of bits for testing
            //shift to the bit which will dictate true or false
            Integer tBitVal = ((Integer)(Math.Pow(2, shiftBits)) & pFullValue) >> shiftBits;
            return  tBitVal == 1;
        }
    }
}