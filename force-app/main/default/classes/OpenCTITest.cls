@isTest 
public class OpenCTITest {

    @isTest static void testName() {
        PageReference pagina = Page.IVRCall;
        Test.setCurrentPage(pagina);
        
        pagina.getParameters().put('sfdcIframeOrigin','https://colmenaseguros--uat--c.sandbox.vf.force.com/');
        pagina.getParameters().put('ANI','3152854092');
        pagina.getParameters().put('UCID','00001099761698704595');
        pagina.getParameters().put('DNIS','1120244');
        pagina.getParameters().put('UUI','1,6547892310,0,1,0,ABCDEFGHIJKLMNOPQRST,2024/05/09 17:44:30');
        OpenCTI testCTI = new OpenCTI();
        testCTI.redirect();
    }
    
    @isTest static void testName1() {
        PageReference pagina = Page.IVRCall;
        Test.setCurrentPage(pagina);
        
        pagina.getParameters().put('sfdcIframeOrigin','https://colmenaseguros--uat--c.sandbox.vf.force.com/');
        pagina.getParameters().put('ANI','3152854092');
        pagina.getParameters().put('UCID','00001099761698704595');
        pagina.getParameters().put('DNIS','1120244');
        pagina.getParameters().put('UUI','2,6547892310,0,1,0018F00000QDkvmQAD,ABCDEFGHIJKLMNOPQRST,2024/05/09 17:44:30');
        OpenCTI testCTI = new OpenCTI();
        testCTI.redirect();
    }
    
    @isTest static void testName2() {
        PageReference pagina = Page.IVRCall;
        Test.setCurrentPage(pagina);
        
        pagina.getParameters().put('sfdcIframeOrigin','https://colmenaseguros--uat--c.sandbox.vf.force.com/');
        pagina.getParameters().put('ANI','3152854092');
        pagina.getParameters().put('UCID','00001099761698704595');
        pagina.getParameters().put('DNIS','1120244');
        pagina.getParameters().put('UUI','3,6547892310,0,1,0,ABCDEFGHIJKLMNOPQRST,2024/05/09 17:44:30');
        OpenCTI testCTI = new OpenCTI();
        testCTI.redirect();
    }
    
    @isTest static void testName3() {
        PageReference pagina = Page.IVRCall;
        Test.setCurrentPage(pagina);
        
        pagina.getParameters().put('sfdcIframeOrigin','https://colmenaseguros--uat--c.sandbox.vf.force.com/');
        pagina.getParameters().put('ANI','3152854092');
        pagina.getParameters().put('UCID','00001099761698704595');
        pagina.getParameters().put('DNIS','1120244');
        pagina.getParameters().put('UUI','4,6547892310,0,1,0!!!!!XYM,ABCDEFGHIJKLMNOPQRST,2024/05/09 17:44:30');
        OpenCTI testCTI = new OpenCTI();
        testCTI.redirect();
    }
    @isTest static void testName4() {
        PageReference pagina = Page.IVRCall;
        Test.setCurrentPage(pagina);
        
        pagina.getParameters().put('sfdcIframeOrigin','https://colmenaseguros--uat--c.sandbox.vf.force.com/');
        pagina.getParameters().put('ANI','3152854092');
        pagina.getParameters().put('UCID','00001099761698704595');
        pagina.getParameters().put('DNIS','1120244');
        pagina.getParameters().put('UUI','1,6547892310,0,1,0,ABCDEFGHIJKLMNOPQRST,2024/05/09 17:44:30');
        OpenCTI testCTI = new OpenCTI();
        testCTI.loadData();
    }
    
    @isTest static void testName5() {
        PageReference pagina = Page.IVRCall;
        Test.setCurrentPage(pagina);
        
        pagina.getParameters().put('sfdcIframeOrigin','https://colmenaseguros--uat--c.sandbox.vf.force.com/');
        pagina.getParameters().put('ANI','3152854092');
        pagina.getParameters().put('UCID','00001099761698704595');
        pagina.getParameters().put('DNIS','1120244');
        pagina.getParameters().put('UUI','2,6547892310,0,1,0,ABCDEFGHIJKLMNOPQRST,2024/05/09 17:44:30');
        OpenCTI testCTI = new OpenCTI();
        testCTI.loadData();
    }

    @isTest static void testName6() {
        PageReference pagina = Page.IVRCall;
        Test.setCurrentPage(pagina);
        
        pagina.getParameters().put('sfdcIframeOrigin','https://colmenaseguros--uat--c.sandbox.vf.force.com/');
        pagina.getParameters().put('ANI','3152854092');
        pagina.getParameters().put('UCID','00001099761698704595');
        pagina.getParameters().put('DNIS','1120244');
        pagina.getParameters().put('UUI','3,6547892310,0,1,0,ABCDEFGHIJKLMNOPQRST,2024/05/09 17:44:30');
        OpenCTI testCTI = new OpenCTI();
        testCTI.loadData();
    }

        @isTest static void testName7() {
        PageReference pagina = Page.IVRCall;
        Test.setCurrentPage(pagina);
        
        pagina.getParameters().put('sfdcIframeOrigin','https://colmenaseguros--uat--c.sandbox.vf.force.com/');
        pagina.getParameters().put('ANI','3152854092');
        pagina.getParameters().put('UCID','00001099761698704595');
        pagina.getParameters().put('DNIS','1120244');
        pagina.getParameters().put('UUI','4,6547892310,0,1,0,ABCDEFGHIJKLMNOPQRST,2024/05/09 17:44:30');
        OpenCTI testCTI = new OpenCTI();
        testCTI.loadData();
    }

}