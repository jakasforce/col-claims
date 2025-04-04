/*
* ===================================================================================
* @className        CS_QueubleUserACK
* @description      Class Queueable to call the service of UserACK moment 4
* @author           JP
* @version          V0.1 
* @testClass        CS_GetUser_Test
* @dateCreated      2022-11
* ==============================================================================================================================
*/ 
public class CS_QueubleUserACK implements Queueable, Database.AllowsCallouts{
    
    public Set<String> setNumeroidCF;
    public String entityValue;
    
    public CS_QueubleUserACK(Set<String> setNumeroidCF, String entityValue){
        this.setNumeroidCF = setNumeroidCF;
        this.entityValue = entityValue;
    }

    public void execute(QueueableContext qc){
        
        Set<String> setEnvioNumeroidCF = new Set<String>();
        integer cantidad = 1;
        integer control= 1;
        //recorresmos valores de usuarios recibidos para control de envio de ACK no superior a 100
        FOR(String valor: setNumeroidCF){
            setEnvioNumeroidCF.add(valor);
            if(cantidad == setNumeroidCF.size() || control == 99){
                CS_GetUser.ackUserFuture(setEnvioNumeroidCF,entityValue);
                setEnvioNumeroidCF.clear();
                control = 1;
            }else{
                control = control  + 1;
            }
            cantidad = cantidad + 1;
            
        }     
    }

}