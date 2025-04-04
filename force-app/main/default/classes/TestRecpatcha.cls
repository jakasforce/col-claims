/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 08-21-2024
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
public with sharing class TestRecpatcha {
    
    @AuraEnabled(cacheable=true)
    public static String validateCaptcha(String userToken) {
        
        // Instantiate a new Http object
        Http h = new Http();

        String secret = '6LeQwQ0qAAAAAJjz2wiccIovJzAZfdTWjomHG6EU';
        String response = '03AFcWeA4MZu1qAXmQ2GP1afFIiuC8FG_DiqI-jbHjBjdYmfaAZWIpMvne3PMQ7eSpH_8UD_4gqd2jbnK2vpEFBX12mFreFvCBMa5Isu35-AcFpQE5UK-3fPN_z2MLEHefpGRoQKFaGBqA9kwNHkvMaHJapEcGPRoKt_HxwggTYc8RxhX4DLty_QfD2v986-CrrETUYk5HylXMIOelM7LV0H1jVW1MhANtvn-YC7wEOxQcrzZe7xS8J82gFqwImT_QdQ7zTfFj63dLSy3EDqS-gkUaQ4cqciy_mRDzoE2vz4KgIgQxZv9XfxXsSnn5CR0Fqk-xMkfzESHnkFbl0wtKRc6HrfBsemcrKwpKVmJ5g7ZeWDIV8xUvkQBJ1c75ualnIEdWLl5XMG7SI_vB506Z6HoQJWl3YoajOh-Ydf_Q1HQouL0YbRt0gHw1EYUuKwX3IKiNjeZHwBhiPOYRP4_DXtinnKAy5HYczOKTyJARHi92648-aaNj2jvHUfX8PE_WF4xbRtJ48XyktgdRjkguLsnu0DrSl7MTx7-GdMoeAElU7fj-8jSoxXQbFRDjqu364z4QlitaPhkk06MOrC_vXgL4klLECfuEssAnCeiOMgRUH82lUd62xDoEKVBWl4J-uS4GGKd91KjJ1ulpabEKFUMJx_9JfogveS3Nfg-xcmrYLm-ZqH-rlTBwaZ-sHCfEwB3o7hSX3aKJ6uKXOqAZ18xBbYJDHqytC4PfJ8UY3JX_dXXF3q4zOuLN4Jg9OxuleQrHGBByGy2mB6-_UpAJqxeWTor_nKTsRqo-fKG1h_1Pam6mWFR3O8wZiVRLyxFYeVfOZXVvtzWWMRMYk_THIQ3G_0AZKK1NEwDXWOxehRvUtGvQMx4zxrPksJGySz9iLcHviapzS37og5qqKMakiCAT02JMmiedid39tkOV6fHHsE0nBQMAgcvswYOkM5qN2tepyRJby4Tm27rJXlI4mP4l7QW3FVEUjsK-Hl1X7JKN_mwA_SkaFvoQ876VXVgoeZlhPtN6i785m1vtKSA6NOqLuOQ5An9duh9XxXAY47GjVkxDOA13tGLFcqJi5e4vHXsiZMRf-bLRwXE0_c6Wthbq2Xnq73cijc1Nu4tL7RCDv6z5tLQVDkpYSDDWe6XNXnLUpe3DTvpfm0thN9UbF2k-mCI8xyzz-hrAs5TY7tTNIzqxpYmOe6-ZHcNs2coGwnm1vmtENojxNNJq_TYsgy-H8zbA4ph-esBOFt789nRB6cuR8Vk9DaNZ0hH13nGM78zJZGTvomM0tPw6IfpC3uy_15aT_B8W4NIL_WjEevAXJ5KUHu5vaGo75NzJ6MzihFFtczCWx_gnEAoW8DkeZif70MEnZx48Q42juLYheinUYLqIodg_hCv5hh5BUwdCtfDsHETvnuoSPQBBbdsk5Af8ERamhKCzp4pW3Vy_TWIUNosOJ6IgRI1s0aTsot4XHJrB7Zp51bvCiZBNQt1pSo8XiOIGw28-9IJF0TOjtAJKS3s8NWKzhxNjvGN9QLMSaxwl9e7AkiCf7jYDSO-boIW2UldJd-3fvCwP0zGV3xMP45wkFHo7ihFfMa2comZTrgk02KMm039XVY03FZlBTR1cm5mXgiEbWxCPoCKnLgV9_L-V13aQqu_vyBh4fe8E1ix6scqRabSn4mqE4ZuSkY-duK1Mf-PGqfieMY5-KrttwprrGv4He5Ek7DrZ-tRI6Qrjl40Aw0v947BBwakf5BrgbNGR727MC5wcee_3_dnzoHGcEnc-MH6mYoE2Ism1idZae9-Vv6PveJOJjySsNv81DktNdboaB5FPLq5qvoNT3PGMXRvhKeW_h7cmHjvjzA4H6gBe6Hg3aAzV_L0Cc7Ay4y6V1FDdrnzesvOHnffVPrXDVtaopMygJKEytqZLwvEbqFoXo94DozFwBPuhzAGy1XUBPua9Tw';

        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
        req.setMethod('POST');
        req.setHeader('Content-Length', '0');
        req.setbody('secret=' + secret + '&response=' + response);
        //req.setHeader('secret', '6LeQwQ0qAAAAAJjz2wiccIovJzAZfdTWjomHG6EU');
        //req.setHeader('response', '03AFcWeA4MZu1qAXmQ2GP1afFIiuC8FG_DiqI-jbHjBjdYmfaAZWIpMvne3PMQ7eSpH_8UD_4gqd2jbnK2vpEFBX12mFreFvCBMa5Isu35-AcFpQE5UK-3fPN_z2MLEHefpGRoQKFaGBqA9kwNHkvMaHJapEcGPRoKt_HxwggTYc8RxhX4DLty_QfD2v986-CrrETUYk5HylXMIOelM7LV0H1jVW1MhANtvn-YC7wEOxQcrzZe7xS8J82gFqwImT_QdQ7zTfFj63dLSy3EDqS-gkUaQ4cqciy_mRDzoE2vz4KgIgQxZv9XfxXsSnn5CR0Fqk-xMkfzESHnkFbl0wtKRc6HrfBsemcrKwpKVmJ5g7ZeWDIV8xUvkQBJ1c75ualnIEdWLl5XMG7SI_vB506Z6HoQJWl3YoajOh-Ydf_Q1HQouL0YbRt0gHw1EYUuKwX3IKiNjeZHwBhiPOYRP4_DXtinnKAy5HYczOKTyJARHi92648-aaNj2jvHUfX8PE_WF4xbRtJ48XyktgdRjkguLsnu0DrSl7MTx7-GdMoeAElU7fj-8jSoxXQbFRDjqu364z4QlitaPhkk06MOrC_vXgL4klLECfuEssAnCeiOMgRUH82lUd62xDoEKVBWl4J-uS4GGKd91KjJ1ulpabEKFUMJx_9JfogveS3Nfg-xcmrYLm-ZqH-rlTBwaZ-sHCfEwB3o7hSX3aKJ6uKXOqAZ18xBbYJDHqytC4PfJ8UY3JX_dXXF3q4zOuLN4Jg9OxuleQrHGBByGy2mB6-_UpAJqxeWTor_nKTsRqo-fKG1h_1Pam6mWFR3O8wZiVRLyxFYeVfOZXVvtzWWMRMYk_THIQ3G_0AZKK1NEwDXWOxehRvUtGvQMx4zxrPksJGySz9iLcHviapzS37og5qqKMakiCAT02JMmiedid39tkOV6fHHsE0nBQMAgcvswYOkM5qN2tepyRJby4Tm27rJXlI4mP4l7QW3FVEUjsK-Hl1X7JKN_mwA_SkaFvoQ876VXVgoeZlhPtN6i785m1vtKSA6NOqLuOQ5An9duh9XxXAY47GjVkxDOA13tGLFcqJi5e4vHXsiZMRf-bLRwXE0_c6Wthbq2Xnq73cijc1Nu4tL7RCDv6z5tLQVDkpYSDDWe6XNXnLUpe3DTvpfm0thN9UbF2k-mCI8xyzz-hrAs5TY7tTNIzqxpYmOe6-ZHcNs2coGwnm1vmtENojxNNJq_TYsgy-H8zbA4ph-esBOFt789nRB6cuR8Vk9DaNZ0hH13nGM78zJZGTvomM0tPw6IfpC3uy_15aT_B8W4NIL_WjEevAXJ5KUHu5vaGo75NzJ6MzihFFtczCWx_gnEAoW8DkeZif70MEnZx48Q42juLYheinUYLqIodg_hCv5hh5BUwdCtfDsHETvnuoSPQBBbdsk5Af8ERamhKCzp4pW3Vy_TWIUNosOJ6IgRI1s0aTsot4XHJrB7Zp51bvCiZBNQt1pSo8XiOIGw28-9IJF0TOjtAJKS3s8NWKzhxNjvGN9QLMSaxwl9e7AkiCf7jYDSO-boIW2UldJd-3fvCwP0zGV3xMP45wkFHo7ihFfMa2comZTrgk02KMm039XVY03FZlBTR1cm5mXgiEbWxCPoCKnLgV9_L-V13aQqu_vyBh4fe8E1ix6scqRabSn4mqE4ZuSkY-duK1Mf-PGqfieMY5-KrttwprrGv4He5Ek7DrZ-tRI6Qrjl40Aw0v947BBwakf5BrgbNGR727MC5wcee_3_dnzoHGcEnc-MH6mYoE2Ism1idZae9-Vv6PveJOJjySsNv81DktNdboaB5FPLq5qvoNT3PGMXRvhKeW_h7cmHjvjzA4H6gBe6Hg3aAzV_L0Cc7Ay4y6V1FDdrnzesvOHnffVPrXDVtaopMygJKEytqZLwvEbqFoXo94DozFwBPuhzAGy1XUBPua9Tw');

        // Send the request, and return a response
        HttpResponse res = h.send(req);
        System.debug('RESULTADO: ' + res.getBody());

        return res.getBody();
    }
}