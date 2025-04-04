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
</Workflow>
