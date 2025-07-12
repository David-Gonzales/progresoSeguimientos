public with sharing class SeguimientoController {
    @AuraEnabled(cacheable=true)
    public static List<Seguimiento__c> getSeguimientos(Id contactoId) {
        return [
            SELECT Id, Name, Etapa__c
            FROM Seguimiento__c
            WHERE Contacto__c = :contactoId
        ];
    }
}