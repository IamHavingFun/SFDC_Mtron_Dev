/****************************************************************************************
  * @filename      : InspectionConfirmationPdfController
  * @projectname   :
  * @author        : jy.kim
  * @date          : 2020-07-02
  * @group         :
  * @group-content :
  * @description   :
  * @tester        : InspectionConfirmationPdfController_ts.cls
  * @reference     :
  * @copyright     : Copyright © I2max. All Rights Reserved.
  * @modification Log
  * ===============================================================
  * ver     date            author         description
  * ===============================================================
    0.1     2020-07-02         jy.kim          Create
****************************************************************************************/

public with sharing class InspectionConfirmationPdfController {
    public String pdiId {get;set;} // PDI Id
    public PDI__c pdi {get;set;}   // 대상 PDI
    public static final Integer DEFAULT_LINE_LENGTH = 20; // PDF 출력을 위한 글자 자르기 길이
    public static final String NEW_LINE = '\n'; // 줄바꿈 태그
    private static String SPLIT_CHARS = ' '; // Spilt 태그
    public String actionText {get;set;}

    public InspectionConfirmationPdfController(){
        pdiId = ApexPages.currentPage().getParameters().get('pdiId');
        pdi = new PDI__c();
        pdiSearch();
    }

    public void pdiSearch(){
        pdi = [select id,Name,Asset__r.Name, Asset__r.Product2.Name,Asset__r.Product2.ProductType__c,Consumer__r.fm_Mobile__c,Consumer__r.Name,Owner.Name,CreatedDate,
                HandoverDate__c,Consumer__r.BillingState,Consumer__r.BillingCity,Consumer__r.BillingStreet,Action__c,Consumer__r.RecordType.DeveloperName,
                Consumer__r.PersonMobilePhone,Consumer__r.Mobile__c,
                Education1__c,Education2__c,Education3__c,Education4__c,Education5__c,Education6__c,Education7__c,Education8__c,Education9__c,
                Check1_1__c,Check1_2__c,Check1_3__c,Check1_4__c,Check1_5__c,Check1_6__c,Check1_7__c,Check1_8__c,Check1_9__c,
                Check2_1__c,Check2_2__c,Check2_3__c,Check2_4__c,Check2_5__c,Check2_7__c,Check2_8__c,
                Check3_1__c,Check3_2__c,Check3_3__c,Check3_4__c,Check3_5__c,Check3_6__c,Check3_7__c,ETC__c,CustomerSignatureApex__c
                from PDI__c where id = :pdiId];

        actionText = splitLines(pdi.Action__c,DEFAULT_LINE_LENGTH);
    }


    private static String splitLines(String input, Integer lineLength) {
        if (input == null) return input;
        List<String> finalLines = new List<String>();
        for (String singleLine : input.split('\n')) {
            finalLines.add(splitLinesSingleLine(singleLine, lineLength));
        }
        return String.join(finalLines, NEW_LINE);
    }

    private static String splitLinesSingleLine(String input, Integer lineLength) {
        if (lineLength == null) { lineLength = DEFAULT_LINE_LENGTH; }
        if (input == null || input.length() <= lineLength) return input;

        String[] words = explode(input, SPLIT_CHARS);

        Integer curLineLength = 0;
        List<String> strBuilder = new List<String>();
        for(Integer i = 0; i < words.size(); i += 1)
        {
            String word = words[i];
            if (curLineLength + word.length() > lineLength) {
                if (curLineLength > 0) {
                    strBuilder.add(NEW_LINE);
                    curLineLength = 0;
                }

                while (word.length() > lineLength) {
                    strBuilder.add(word.subString(0, lineLength - 1) + '');
                    word = word.subString(lineLength - 1);
                    strBuilder.add(NEW_LINE);
                }

                word = word.trim();
            }
            strBuilder.add(word);
            curLineLength += word.length();
        }

        String combinedLine = String.join(strBuilder, '');
        combinedLine = combinedLine.replaceAll('\\s*<br/>', '<br/>');
        return combinedLine;
    }

    private static String[] explode(String str, String splitCharacters) {
        List<String> parts = new List<String>();
        if (str != null) {
            Integer startIndex = 0;
            while (true) {
                Integer preIndex = str.subString(startIndex).indexOfAny(splitCharacters);
                Integer index = startIndex + preIndex;

                if (preIndex == -1) {
                    parts.add(str.subString(startIndex));
                    break;
                }

                String word = str.subString(startIndex, index);
                String nextChar = str.subString(index, index + 1);

                if (nextChar.isWhiteSpace()) {
                    parts.Add(word);
                    parts.Add(nextChar);
                } else {
                    parts.Add(word + nextChar);
                }

                startIndex = index + 1;
            }
        }
        return parts;
    }
}