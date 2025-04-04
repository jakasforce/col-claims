<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SendEmailClaimCreated</fullName>
        <description>Send email by claim created</description>
        <protected>false</protected>
        <recipients>
            <field>ClaimEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>servicioalclientevida@colmenaseguros.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ColmenaBuzn/Basic_Template_1698104400823</template>
    </alerts>
    <alerts>
        <fullName>SendEmailGroundObjection</fullName>
        <description>Envio correo de causal de objecion radicacion claim</description>
        <protected>false</protected>
        <recipients>
            <field>ClaimEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>servicioalclientevida@colmenaseguros.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ColmenaBuzn/Email_Template_Ground_Objetion_1702412871392</template>
    </alerts>
    <alerts>
        <fullName>SendEmailStatusInPayer</fullName>
        <description>Envio correo status en pagador radicacion claim</description>
        <protected>false</protected>
        <recipients>
            <field>ClaimEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>servicioalclientevida@colmenaseguros.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ColmenaBuzn/Email_Template_In_Payer_1702413946581</template>
    </alerts>
    <alerts>
        <fullName>SendEmailStatusInSuspended</fullName>
        <description>Envio correo status suspendido radicacion claim</description>
        <protected>false</protected>
        <recipients>
            <field>ClaimEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>servicioalclientevida@colmenaseguros.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ColmenaBuzn/COLMENASUSPENDED/Email_Template_Status_Suspended_1702408261583</template>
    </alerts>
    <alerts>
        <fullName>SendEmailStatusPaid</fullName>
        <description>Envio correo status pagado radicacion claim</description>
        <protected>false</protected>
        <recipients>
            <field>ClaimEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>servicioalclientevida@colmenaseguros.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ColmenaBuzn/Email_Template_In_Payer_1702413761641</template>
    </alerts>
    <alerts>
        <fullName>SendEmailStatusPartialPayment</fullName>
        <description>Envio correo status pago parcial radicacion claim</description>
        <protected>false</protected>
        <recipients>
            <field>ClaimEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>servicioalclientevida@colmenaseguros.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ColmenaBuzn/Email_Template_Partial_Payment_1702414132911</template>
    </alerts>
    <alerts>
        <fullName>SendUpdateClaim</fullName>
        <description>Envio Correo Actualizacion Claim</description>
        <protected>false</protected>
        <recipients>
            <field>ClaimEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>servicioalclientevida@colmenaseguros.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ColmenaBuzn/Notification_Update_Claim_1712002534206</template>
    </alerts>
    <alerts>
        <fullName>sendEmailCreateClaim</fullName>
        <description>Envio de correo radicación claim</description>
        <protected>false</protected>
        <recipients>
            <field>ClaimEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>servicioalclientevida@colmenaseguros.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/BasicTemplate</template>
    </alerts>
</Workflow>
