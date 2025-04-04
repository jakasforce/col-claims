public class ValidationCodeGenerate {
	@InvocableMethod(label='Codigo de Verificación Bot')
    public static List<String> getCode() {
        List<String> cod = new List<String>();
        String codigo = String.valueOf(Math.round((Math.random() * (900000) + 100000)));
        System.debug(codigo);    	
        cod.add(codigo);
        return cod;
    }
}