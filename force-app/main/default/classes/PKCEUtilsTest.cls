/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 12-16-2024
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
@isTest
public class PKCEUtilsTest {

    // Prueba del método generateCodeVerifier
    @isTest
    static void testGenerateCodeVerifier() {
        String codeVerifier = PKCEUtils.generateCodeVerifier();

        // Validar que no sea nulo o vacío
        System.assertNotEquals(null, codeVerifier, 'El code_verifier no debe ser nulo');
        System.assertNotEquals('', codeVerifier, 'El code_verifier no debe estar vacío');

        // Validar longitud dentro del rango permitido
        System.assert(codeVerifier.length() >= 43 && codeVerifier.length() <= 128,
                      'El code_verifier debe tener entre 43 y 128 caracteres');

        // Validar que contenga solo caracteres válidos
        String allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
        for (Integer i = 0; i < codeVerifier.length(); i++) {
            String character = codeVerifier.substring(i, i + 1);
            System.assert(allowedChars.contains(character), 'El code_verifier contiene caracteres inválidos');
        }
    }

    // Prueba del método generateCodeChallenge
    @isTest
    static void testGenerateCodeChallenge() {
        // Generar un code_verifier de prueba
        String codeVerifier = PKCEUtils.generateCodeVerifier();
        String codeChallenge = PKCEUtils.generateCodeChallenge(codeVerifier);

        // Validar que no sea nulo o vacío
        System.assertNotEquals(null, codeChallenge, 'El code_challenge no debe ser nulo');
        System.assertNotEquals('', codeChallenge, 'El code_challenge no debe estar vacío');

        // Validar que no tenga caracteres de padding o inválidos en Base64 URL-safe
        System.assert(!codeChallenge.contains('+') && !codeChallenge.contains('/') && !codeChallenge.contains('='),
                      'El code_challenge debe estar en formato Base64 URL-safe');
    }

    // Prueba del método generatePKCEParameters
    @isTest
    static void testGeneratePKCEParameters() {
        Map<String, String> pkceParams = PKCEUtils.generatePKCEParameters();

        // Validar que el mapa contiene las claves necesarias
        System.assert(pkceParams.containsKey('code_verifier'), 'El mapa debe contener code_verifier');
        System.assert(pkceParams.containsKey('code_challenge'), 'El mapa debe contener code_challenge');

        // Validar que los valores no sean nulos ni vacíos
        String codeVerifier = pkceParams.get('code_verifier');
        String codeChallenge = pkceParams.get('code_challenge');
        System.assertNotEquals(null, codeVerifier, 'El code_verifier no debe ser nulo');
        System.assertNotEquals('', codeVerifier, 'El code_verifier no debe estar vacío');
        System.assertNotEquals(null, codeChallenge, 'El code_challenge no debe ser nulo');
        System.assertNotEquals('', codeChallenge, 'El code_challenge no debe estar vacío');

        // Validar que el code_challenge fue generado correctamente
        String expectedChallenge = PKCEUtils.generateCodeChallenge(codeVerifier);
        System.assertEquals(expectedChallenge, codeChallenge, 'El code_challenge debe coincidir con el esperado');
    }
}
