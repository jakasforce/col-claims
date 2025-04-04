/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 02-24-2025
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
global with sharing class AzureB2CRegisterHandler implements Auth.RegistrationHandler {
    
    private static final String ORG_SUFFIX = System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName();
    private static final String TIME_ZONE = 'America/Bogota';
    private static final String NOT_FOUND_ERROR = 'The user is not registered in the system';

    /**
    * @description Let anyone register as long as the required fields are supplied
    * @author diego.jacanamijoy@oc.vasscompany.com | 12-20-2023 
    * @param data 
    * @return boolean 
    **/
    global boolean canCreateUser(Auth.UserData data) {

        Boolean retVal = (data != null 
                && data.email != null
                && data.lastName != null
                && data.firstName != null);
        
        return retVal;
    }

    /**
    * @description A required method to implement the Handler Interface
    * @author diego.jacanamijoy@oc.vasscompany.com | 12-20-2023 
    * @param portalId 
    * @param data 
    * @return User 
    **/
    global User createUser(Id portalId, Auth.UserData data){
        if(!canCreateUser(data)) {
            // Returning null signals the auth framework we can't create the user
            return null;
        }

        //Check if exist user in the org
        List<User> user = [SELECT 
                                Email, FirstName, LastName 
                            FROM User 
                            WHERE Email =: data.email
                            AND IsActive = true
                            ];
        if (user.size() > 0) {
            return user[0];
        } else {
            throw new RegisterHandlerException(NOT_FOUND_ERROR);
        }
        
        //Get an internal profile
        //Profile p = [SELECT Id FROM profile WHERE name =: 'Standar User' WITH SYSTEM_MODE];
            
        //Get methos to create user
        //User u = createUser(data,p);

        //return user[0];
    }

    
    /**
    * @description 
    * @author diego.jacanamijoy@oc.vasscompany.com | 12-20-2023 
    * @param userId 
    * @param portalId 
    * @param data 
    **/
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        
        User u = new User(id = userId);
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        update(u);
    }
    
    /**
    * @description 
    * @author diego.jacanamijoy@oc.vasscompany.com | 12-20-2023 
    * @param data 
    * @param p 
    * @return User 
    **/
    /*private User createUser(Auth.UserData data, Profile p) {
        User u = new User();
        u.username = data.email + (ORG_SUFFIX == null ? '' : ('.' + ORG_SUFFIX));
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        String alias = data.firstName + data.lastName;
        
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLanguage();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = TIME_ZONE;
        
        return u;
    }*/

    // Custom exception for errors related to the AutoNumberGenerator
    public class RegisterHandlerException extends Exception {}
}