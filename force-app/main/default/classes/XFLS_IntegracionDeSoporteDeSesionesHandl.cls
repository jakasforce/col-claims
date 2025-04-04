public class XFLS_IntegracionDeSoporteDeSesionesHandl {
/*--------------------------------------------------------------
    * Nombre del método: EntityID 
    * Descripción      : 
    * @parámetro       : {List <Id>} EntityID 
    * @return          : {void} 
    --------------------------------------------------------------*/
    @future (callout = true)
    public static void ContentDocumentLinkId(List <Id> ContentDocumentL){
        List <ContentDocumentLink> contentDoc = [SELECT Id,LinkedEntityID,ContentDocumentId
                                                 FROM ContentDocumentLink 
                                                 WHERE Id IN: ContentDocumentL];
        for(ContentDocumentLink cd : contentDoc){
            XFLS_IntegracionSoporteDeSesiones.soporteDeSesiones(cd);
        }
    }
}