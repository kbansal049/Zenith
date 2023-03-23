public with sharing class PerformEncryptionDecryption {

    public static String performEncryption(String stringToEncrypt, String initializationVectorStr, String key){

        //Data to encrypt is converted to Blob
        Blob data = Blob.valueOf(stringToEncrypt);

        //128 bit key for encryption
        Blob encryptionKey = Blob.valueOf(key);

        //Initialization Vector
        Blob initializationVector = Blob.valueOf(initializationVectorStr);

        //Encrypt the data using AES128
        Blob encryptedData = Crypto.encrypt('AES128', encryptionKey, initializationVector, data);

        //Encrypted data
        String encryptedString = EncodingUtil.base64Encode(encryptedData);

        return encryptedString;
    }

    public static String performDecryption(String stringToDecrypt, String initializationVectorStr, String key){

        //Data to decrypt is converted to Blob
        Blob data = EncodingUtil.Base64Decode(stringToDecrypt);
        
        Blob encryptionKey = Blob.valueOf(key);
        //Initialization Vector
        Blob initializationVector = Blob.valueOf(initializationVectorStr);

        //Decrypt the encrypted data using AES128
        Blob decryptedData = Crypto.decrypt('AES128', encryptionKey, initializationVector, data);

        return decryptedData.toString();
    }
}