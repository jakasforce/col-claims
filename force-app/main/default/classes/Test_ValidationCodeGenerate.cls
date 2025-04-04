@isTest
private class Test_ValidationCodeGenerate {
    @isTest static void myTest() {
        List<String> codigo = ValidationCodeGenerate.getCode();
        System.AssertNotEquals(null, codigo );
    }
}