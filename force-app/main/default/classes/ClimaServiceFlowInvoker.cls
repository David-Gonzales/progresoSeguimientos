public class ClimaServiceFlowInvoker {
    @InvocableMethod
    public static void invocarClima(List<Id> seguimientoIds) {
        for (Id id : seguimientoIds) {
            ClimaService.obtenerClima(id);
        }
    }
}