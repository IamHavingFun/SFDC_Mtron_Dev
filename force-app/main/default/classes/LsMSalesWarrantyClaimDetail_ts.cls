/****************************************************************************************
 * @filename      : LsMSalesWarrantyClaimDetail_ts
 * @projectname   : 
 * @author        : SEOKHO LEE
 * @date          : 2020-07-07 오전 11:20
 * @group         :
 * @group-content :
 * @description   :
 * @tester        :
 * @reference     :
 * @copyright     : Copyright © I2max. All Rights Reserved.
 * @modification Log
 * ===============================================================
 * ver     date                     author              description
 * ===============================================================
 0.1     2020-07-07 오전 11:20        SEOKHO LEE          Create
 ****************************************************************************************/

@IsTest
private class LsMSalesWarrantyClaimDetail_ts {
    @isTest
    static void testBehavior() {

        WarrantyClaim__c wc = new WarrantyClaim__c();
        wc.ProductId__c = TestDataProductFactory.baseProduct2.Id;
        wc.AssetId__c = TestDataSalesFactory.baseAsset.Id;
        wc.Customer__c = TestDataBaseFactory.businessOfficeAccount.Id;
        wc.ClaimResult__c = '';
        wc.ClaimStatus__c = '0.저장';
        wc.ClaimNo__c = '12345678';
        insert wc;

        LsMSalesWarrantyClaimDetail.DetailData detailData = LsMSalesWarrantyClaimDetail.init(wc.Id);
        LsMSalesWarrantyClaimDetail.save(detailData);

        ContentVersion o_cv = new ContentVersion(
                Title = 'test1',
                PathOnClient = 'editImegeTest.PNG',
                ContentUrl = '',
                LWSImageType__c = '기대정보',
                VersionData = Blob.valueOf('iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAIAAAC1nk4lAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAABIlJREFUeNrUmjFMGzEUhmMnS7qkDWsQ0IE1oRtTW1grkSLRNcBEJwpjGRASdAQxlamQtZVaUFlLYWKrwtgMhaqstOkSpth9viMX39l353PsK1iRQKDcfXl573//sw9RSjN3beHMHVw5jffQ5jFtnrDf2q3MvfvwE5XKaLCSGRi+jdD0dI98Xsv8/hn8u/ujOIQqVTReYx/A5kKqOd1ukfocPTtQuigEfnIRjc/+V2gg3nxKL8+SXTtfQJOv8MSim0JpQ5P1scTEHDp+sWU26vHqQd4v6RPDuv5L6vOd1yNQvilFGu5ENieM3Wy8hme2+s+WSOh2q7M+JmpFXwuypbYLImMrPcjRtmFiN1t2piHlmMabj/TVRWfloUWtBVmEkGspemikyeGa1QYBxc1k9HTPHPTVBT2tW2/HjrBoREcOTVIg9kJ+uAa91kBOd5YeQBjSNG6Q4nj5q6IaYqkrUiXOF9jLXIorSooMunGgSAyxYeFJnRtLSlBm5fDMJnyDAWImWJcNg4mkyJ0Twrwvbb/g18D03Hi9LjGz1/V5Pi81WvTNPOHnjs7vYCGSt8/lka69Y07NcdXo2apIDCu7QzSi21mQpCgqT+GXn9SgwWwsF0MzyeX2Rhg/MbuWhnVutyiYBSnZxCJ42vj0iHaPQIlZqsxKidnbQ26vmd9H23SwLDXiuYj0knKj5glNq/WAr8KliuhP/Pmk4NN5YmZ6eEmx0OeprFliX3olmVDcHsbKvDhk11cJ5gRz/25E6blfp72uS8/2zXtuwZxA95DndERCo9HHvE73iAM6bVQ9Aj4Z5h2J5IUpdG+8g7eBTn9Ycuc8qzotruzGD28HK8c38Oj6I0yqd91PLFU91oHtKQkX7F6kVT6xG+8wnba78oXs1h9/pCPD7Is3OKo4Obclf81jNPqkpx5UDTpQr9Z1OuTWOa+KNWcNyKuVkZTHHOxpeIzfX/kGCS3qNIhJesTdyCrtT0MmgQFAtV3ipHWPuD7n6+paG6RUfRrvXlwJGvQb+Fy9oyXHeQnE7FsLcZIxOq0MjQaGEkDzOg2t0bF7c6LXI+tjGh0xQRWVq4kL0eOWEscXRp97DFBRwfS4binGu/P92LZDkivGs1XB5akfTHHEbODlJMVimIGYI8z18325ZsB27JlYcWHOqB5+ijrdJWbbcFazBW4tjOVqOj0wzF6eTnPEfEXihY8a6kF2pqM3scTUzXk2n8Zt/LDhCnQaBgJnQhY1pM9DCSmxdNf9xprSXw2y8UjJbDixDFO9FIh7Oa1yjOBttNkmhq89u3EegcSNWzD/qRjlfMGqQwJ1C2hF1BYCKk8pmnFbvMUhvHwUS+yHNltGCTMYApx9c+4OJrGLkzwQNdCQ1EcpJqD+hpcE2jHEaUJr4MqgK9U0gg3JUKnq4QbVwxvL2Xm4pWqDUnMfXunvTF9yJMcaDeixQW7TjwmFnI072199dhC2uwCs5SnjjzRFPjpxdUG+bLOjI0UfB8kKfDAFwxwJ4mX6KSA1aI6ehm8suYdaqFSxR6kFfcvWnXwC8p8AAwBrXZelQ5kS3AAAAABJRU5ErkJggg==')
        );
        insert o_cv;
        ContentVersion o_cv2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :o_cv.Id];

        ContentVersion n_cv = o_cv.clone(false,true);
        insert n_cv;

        ContentVersion n_cv2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :n_cv.Id];

        try {
            LsMSalesWarrantyClaimDetail.callLWS0022(
                    '1234567890',
                    wc.ClaimNo__c,
                    n_cv2.Id,
                    '1'
            );
        } catch(Exception e) {}

        LsMSalesWarrantyClaimDetail.updateContentVersionItems(
                '',
                n_cv2.ContentDocumentId,
                o_cv2.ContentDocumentId,
                '기대정보'
        );

     }
}