/**
    *   @Class          :   ErrorUtils   
    *
    *   @Author         :   Pedro Párraga <parragabornez.pedrojesus@ext.mpsa.com>
    *   @Created        :   
    *   @Description    :  generic class for handling errors in lightning components
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Modification Log :
    *   ----------------------------------------------------------------------------------------------------------------------------
    *      Developer                Date                     Description    
    *      Pedro Párraga         05/06/2019                   Creation      
    *   ----------------------------------------------------------------------------------------------------------------------------
**/
public with sharing class ErrorUtils {
   public String sName;
   public String sMessage;
   public Integer iCode;
   public String sStack;
   public String sType;
   public String sCause;
   
   public ErrorUtils(String sName, String sMessage, Integer iCode,String sStack,String sType, String sCause){
       this.sName     = sName;
       this.sMessage  = sMessage;
       this.iCode     = iCode;
       this.sStack    = sStack;
       this.sType     = sType;
       this.sCause    = sCause;
   }

}