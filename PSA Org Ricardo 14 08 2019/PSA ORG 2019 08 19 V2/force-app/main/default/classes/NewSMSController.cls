/******************************************************************************************
* Name: 			  NewSMSControllerTest
* Author: 			  Borja Gay
* Description:		  Controller class for NewSMS component
* 
* Changes (Version)
* -----------------------------------------------------------------------------------------
*			No.		Date			          Author		       Description
*			-----	----------		      ----------------	     ---------------
* @version	1.0		2019-07-01		        Borja Gay 	         Initial definition.
*******************************************************************************************/
public with sharing class NewSMSController {

    public class PickListVal{
        String TemplateId;
        String Name; 
    }
    //Request wrapper
    public class SMSRequest {
             List<String> mobileNumbers; 
            boolean Subscribe;
            String Keyword;
            boolean Resubscribe;
            boolean Overridel;
            String MessageText;
    }
    //Response wrapper
    public class SMSResponse{
        String tokenId;
    }
    //login wrapper
    public class Wrp_Login {
        //ClientId and ClientSecret of the external system
        public String clientId;
        public String clientSecret;
    }
    //login response wrapper
    public class Wrp_Login_Response {
        //Token returned by the external system
        public String accessToken;
        public Integer expiresIn;
    }

    /*********************************************************************************************************
    * @Method          :   getCaseInfo
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   String: caseId
    * @Returns         :   List of Strings 
    **********************************************************************************************************/
    @AuraEnabled
    public static List<String> getCaseInfo(string caseId){
        List<Case> lstCase = new List<Case>();
        lstCase = [SELECT id,Country__c,Brand__c from Case where id = :caseId];
        List<String> caseInfo = new List<String>();
        if(!lstCase.isEmpty()){
            caseInfo.add(lstCase[0].Country__c);
            caseInfo.add(lstCase[0].Brand__c);
        }
        //Return country and brand
        return caseInfo;

    }
    /*********************************************************************************************************
    * @Method          :   getPhones
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   String: caseId
    * @Returns         :   List of Strings 
    **********************************************************************************************************/
    @AuraEnabled
    public static List<String> getPhones(String caseId){
        Set<String> setPhones = new Set<String>();
        List<Case> lstCase = new List<Case>();
        lstCase = [select id,ContactPhone, SuppliedPhone, Contact.MobilePhone, Contact.MobilePersonalTelephone__c, Contact.MobileProfessionalTelephone__c from Case where id = :caseId];
        if(!lstCase.isEmpty()){
            if(lstCase[0].ContactPhone != ''){
                setPhones.add(lstCase[0].ContactPhone);
            }
            if(lstCase[0].SuppliedPhone != ''){
                setPhones.add(lstCase[0].SuppliedPhone);
            }
            if(lstCase[0].Contact.MobilePhone != ''){
                setPhones.add(lstCase[0].Contact.MobilePhone);
            }
            if(lstCase[0].Contact.MobileProfessionalTelephone__c != ''){
                setPhones.add(lstCase[0].Contact.MobileProfessionalTelephone__c);
            }
            if(lstCase[0].Contact.MobilePersonalTelephone__c != ''){
                setPhones.add(lstCase[0].Contact.MobilePersonalTelephone__c);
            }
        }
        List<String> lstPhones = new List<String>();
        lstPhones.addAll(setPhones);
        //Return all the phones related to the case
        return lstPhones;
    }
    /*********************************************************************************************************
    * @Method          :   getTemplates
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   String: Country & Brand
    * @Returns         :   String: 
    **********************************************************************************************************/
    @AuraEnabled
    public static String getTemplates(String country, String brand){
        string fiscal = country+'_'+brand+'%';
        System.debug('Fiscal '+fiscal);
        List<EmailTemplate> lstEmail = new List<EmailTemplate>();
        List<PickListVal> lstPCK = new List<PickListVal>();
        lstEmail = [
            SELECT id,FolderId, Name, DeveloperName,Body, IsActive
            FROM EmailTemplate 
            WHERE
                Folder.DeveloperName LIKE '%SMS_Templates%' AND
                DeveloperName like :fiscal
            ];
        if(!lstEmail.isEmpty()){
            for(EmailTemplate et : lstEmail){
                PickListVal pck = new PickListVal();
                pck.TemplateId = et.id;
                pck.Name = et.Name;
                lstPCK.add(pck);
            }
        }
        return JSON.serialize(lstPCK);
    }
    /*********************************************************************************************************
    * @Method          :   loadBody
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   String: templateId
    * @Returns         :   String: body
    **********************************************************************************************************/
    @AuraEnabled
    public static String loadBody(String templatedId){
        string body = '';
        List<EmailTemplate> lstEmail = new List<EmailTemplate>();
        lstEmail =  [SELECT id,FolderId, Name, DeveloperName,Body, IsActive from EmailTemplate where id = :templatedId];
        if(!lstEmail.isEmpty()){
            body = lstEmail[0].Body;
        }
        //Return body of the email template
        return body;
    }
    /*********************************************************************************************************
    * @Method          :   login
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   
    * @Returns         :    
    **********************************************************************************************************/
    @AuraEnabled
    public static String login() {
        //Generic method for login in external systems
        try{
            UtilSetting__mdt smsData = [SELECT id,DeveloperName,Value__c, Value2__c, Value3__c from UtilSetting__mdt where DeveloperName = 'SMSIntegration' limit 1];
            Wrp_Login wrp = new Wrp_Login();
            List<String> clientCreds = smsData.Value3__c.split('/');
            wrp.clientId = clientCreds[0];
            wrp.clientSecret = clientCreds[1];
            
         
            HttpRequest req = new HttpRequest();
            req.setEndpoint(smsData.Value__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            
            String body=JSON.serialize(wrp);
            //Create the JSON automatically
            
            req.setbody(body);
            
            req.setTimeout(10000);
            System.debug('!!!req: ' + req);
            
            Http http = new Http();
            HTTPResponse res;
            
            
            res = http.send(req);
            Wrp_Login_Response responseToken = new Wrp_Login_Response();
            //Deserializes the response into an object
            responseToken = (Wrp_Login_Response)JSON.deserialize(res.getBody(),Wrp_Login_Response.class);
            System.debug('!!!res.getBody(): ' + res.getBody());
            System.debug('responseToken: ' + responseToken);
            System.debug('responseToken.accessToken: ' + responseToken.accessToken);
           return responseToken.accessToken;
            
        }catch(Exception exc){
            return null;
        }
    }
    /*********************************************************************************************************
    * @Method          :   sendSMS
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   String: phone, body, brand, caseId
    * @Returns         :    
    **********************************************************************************************************/
    @AuraEnabled
    public static void sendSMS(String phone, String body, String brand,String caseId){
        try{
            String token = login();
            if(token != null && token != ''){
            List<String> phones = new List<String>();
            phones.add(phone.remove('+'));
            SMSResponse resp = sendRequest(phones,body,brand,token,caseId,0);
            }
     
            //Manage Response data here, if needed
        }
        catch(Exception exc){
            //Do exception managment here
        }
    }
      /*********************************************************************************************************
    * @Method          :   sendRequest
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   String: body, brand, token, caseId  List<String> phones Integer: retrys
    * @Returns         :   SMSResponse
    **********************************************************************************************************/
    public static SMSResponse sendRequest(List<String> phones, String body, String brand,String token,String caseId,integer retrys){
        try{
            List<Case> lstCase = new List<Case>(); 
            lstCase = [SELECT id,CaseNumber,Country__c, Brand__c from Case where id = :caseId];
            UtilSetting__mdt smsData = [SELECT id,DeveloperName,Value__c, Value2__c, Value3__c from UtilSetting__mdt where DeveloperName = 'SMSIntegration' limit 1];
            SMS_Keyword__mdt smsKeyword = [SELECT id,Keyword__c,TemplateId__c from SMS_Keyword__mdt where Country__c = :lstCase[0].Country__c AND Brand__c = :lstCase[0].Brand__c limit 1];  
            SMSRequest wrp=new SMSRequest();
            //Populate request wrapper with the information of the object
            wrp.mobileNumbers = phones;
            wrp.Subscribe=true;
            wrp.Keyword= smsKeyword.Keyword__c;
            wrp.Resubscribe=true;
            wrp.Overridel=true;
            wrp.MessageText=body;
            
            
            HTTPResponse res;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(smsData.Value2__c+smsKeyword.TemplateId__c+'/send');   
            if(token==null){
                if(retrys<3){
                    retrys+=1;
                    login();
                    return sendRequest(phones,body,brand,token,caseId,retrys);
                }else{
                    System.debug('Cannont Connect');
                    //Realizar el logueo en un objeto
                    return null;
                }
            }
            req.setHeader('Authorization', 'Bearer ' + token); //Bearer or Basic
            req.setMethod('POST');//Set the HTTP Method -> POST (Insert), PUT (Update), DELETE (Delete), GET (Read)
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(8000);
            system.debug(req);
            body = JSON.serialize(wrp);
            body = body.replaceAll('"Overridel":','"Override":');
            body = body.replaceAll('CaseNumber',lstCase[0].CaseNumber);

            System.debug(body); //To see the generated body
            req.setBody(body);
            
            Http http = new Http();

            res = http.send(req);
             
            System.debug('!!!status code: ' + res.getStatusCode());            
            System.debug('Body de response: '+res.getBody());  
                
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201  || res.getStatusCode() == 202 || res.getStatusCode() == 203){
                SMSResponse resp = (SMSResponse)JSON.deserialize(res.getBody(),SMSResponse.class);
                return resp;
            }
            else {
                if(retrys<3 && res.getStatusCode() == 401){
                    retrys+=1;
                    login();
                    return sendRequest(phones,body,brand,token,caseId,retrys);
                }
                else{
                    System.debug('Cannont Connect Final');
                    return null;
                }
            }
        }
        catch(Exception exc){
            //Do exception managment here
            return null;
        }
    }
      /*********************************************************************************************************
    * @Method          :   createTask
    * @Author          :   
    * @Created         :   
    * @Description     :   
    * @params	       :   String: caseId, body
    * @Returns         :   String
    **********************************************************************************************************/
    @AuraEnabled
    public static String createTask(String caseId,String body){
        Task tsk = new Task();
        tsk.Subject = 'SMS '+Datetime.now();
        tsk.Description = body;
        tsk.WhatId = caseId;

        insert tsk;
        return tsk.id;
    }
}