/*
-- - Name         : SecurityUtilsLib
-- - Author       : DXC. Ruben Fernandez
-- - Date         : 02/05/2018
-- - Description  : Util Class.
--
-- - History:
-- Date         Author  Version  Comments
-- -----------  -----   -------  ---------------------------------------
-- 02/05/2018   DXC     1.0      Initial version rfernandezlo
*/
public with sharing class SecurityUtilsLib {
     
     private static final Blob crypto192Key          = EncodingUtil.base64Decode(PAD.getToken()); 

     /*
     * @Method          :   getfetchRecords
     * @Author          :   Rubén Fernandez Lopez
     * @Created         :   23/02/2018
     * @Description     :   Wrapper class to hold Columns with headers
     * @Params          :   
     * @Returns         :   
     */ 
    public static String setMask(String sValue){
        
        String sToBeMasked = '';
        String sStart = '';
        System.debug('setMask START ' + sValue);
        if(!String.isEmpty(sValue)){
            Integer iTotal      = sValue.length();
            Integer iPos        = Integer.valueOf(sValue.length()/3);
            sStart              = sValue.left(iPos);
            sToBeMasked         = sStart.rightPad(iTotal-iPos, '*');
        }    
        System.debug('setMask END ' + sToBeMasked);
        return sToBeMasked;
    }

    /**
    * randomWithLimit -                                                             
    * @param upperLimit - Limit ramdom value
    */
    public static Integer randomWithLimit(Integer upperLimit){
        Integer rand = Math.round(Math.random()*1000);
        return Math.mod(rand, upperLimit);
    }

    /**
    * encyptData -                                                             
    * @param decryptedString - String to be encrypted
    */
    public static string encryptData(String decryptedString){
        String base64EncryptedString = '';
        if(decryptedString!=null && decryptedString!=''){
            Blob data               = Blob.valueOf(decryptedString);
            Blob encryptedBlobData  = Crypto.encryptWithManagedIV('AES192', crypto192Key , data );
            base64EncryptedString   = EncodingUtil.base64Encode(encryptedBlobData);
        }
        return base64EncryptedString;
    }    
    /**
    * decryptData -                                                            
    * @param encryptedString - SString to be decrypted
    */
    public static string decryptData(String encryptedString){
        String decryptedString  ='';
        if(encryptedString!=null && encryptedString!=''){
            Blob data               = EncodingUtil.base64Decode(encryptedString);
            Blob decryptedBlobData  = Crypto.decryptWithManagedIV('AES192', crypto192Key , data);
            decryptedString         = decryptedBlobData.toString();
        }
        return decryptedString;
    }
    /**
    * escapeSOSL -                                                            
    * @param sTerm - Search string
    */
    public static String escapeSOSL( String sTerm ) {
        System.debug( '##--> Escaping SOSL term: ' + sTerm );
        String sEscapedText     = null;
        if ( !String.isBlank( sTerm ) ) {

            sEscapedText        = String.escapeSingleQuotes( sTerm ) ;
            // remove special logical operators from the term (case insensitive)
            sEscapedText        = sEscapedText.replaceAll( '(?i)( AND NOT | AND | OR )', ' ' );
            // escape reserved characters
            // ? & | ! { } [ ] ( ) ^ ~ * : \ " ' + -
            Pattern myPattern   = Pattern.compile( '(\\?|\\&|\\||\\!|\\[|\\]|\\(|\\)|\\^|\\~|\\*|\\:|\\"|\\+|\\-)' );
            Matcher myMatcher   = myPattern.matcher( sEscapedText );
            sEscapedText        = myMatcher.replaceAll( '\\\\$1' );
            sEscapedText        = sEscapedText.replaceAll( '( )+', ' ' ).trim();
            sEscapedText        = sEscapedText.replaceAll( '(\\{|\\})', ' ' ).trim();
            
            System.debug( '##--> Escaped SOSL ENTER: ' + sEscapedText );
        }

        System.debug( '##--> Escaped SOSL term: ' + sEscapedText );
        return sEscapedText;
    }
    public static String escapeText( String sText ) {
        String sEscapedText     = null;
        if ( !String.isBlank( sText ) ) {
            sEscapedText        = sText.replaceAll( '\\(','').trim();
            sEscapedText        = sEscapedText.replaceAll( '\\)','').trim();
        }
        return sEscapedText;
    }
   
}