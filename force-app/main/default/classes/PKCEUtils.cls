/**
 * @description       : 
 * @author            : diego.jacanamijoy@oc.vasscompany.com
 * @group             : 
 * @last modified on  : 12-16-2024
 * @last modified by  : diego.jacanamijoy@oc.vasscompany.com
**/
public class PKCEUtils {

    // Método para generar un code_verifier
    public static String generateCodeVerifier() {
        Integer length = 128; // Longitud del code_verifier (entre 43 y 128)
        String allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
        String codeVerifier = ''; // Cadena acumuladora
        for (Integer i = 0; i < length; i++) {
            // Generar índice válido dentro del rango permitido
            Integer randomIndex = Math.abs(Math.mod(Crypto.getRandomInteger(), allowedChars.length()));
            codeVerifier += allowedChars.substring(randomIndex, randomIndex + 1);
        }
        return codeVerifier;
    }

    // Método para calcular el code_challenge basado en el code_verifier
    public static String generateCodeChallenge(String codeVerifier) {
        Blob sha256Hash = Crypto.generateDigest('SHA-256', Blob.valueOf(codeVerifier));
        String base64Encoded = EncodingUtil.base64Encode(sha256Hash);

        // Convertir Base64 a Base64 URL-safe
        String urlSafe = base64Encoded.replace('+', '-').replace('/', '_').replace('=', '');
        return urlSafe;
    }

    // Método para generar ambos valores (opcional)
    public static Map<String, String> generatePKCEParameters() {
        String codeVerifier = generateCodeVerifier();
        String codeChallenge = generateCodeChallenge(codeVerifier);

        return new Map<String, String>{
            'code_verifier' => codeVerifier,
            'code_challenge' => codeChallenge
        };
    }
}
