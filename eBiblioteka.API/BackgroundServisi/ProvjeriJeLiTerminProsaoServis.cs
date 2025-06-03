using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.BackgroundServisi
{
    public class ProvjeriJeLiTerminProsaoServis:BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        public ProvjeriJeLiTerminProsaoServis(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            using var scope = _serviceProvider.CreateScope();
            var terminService = scope.ServiceProvider.GetRequiredService<ITerminServis>();
            while (!stoppingToken.IsCancellationRequested)
            {
                await terminService.ProvjeriJeLiProsao();
                await Task.Delay(TimeSpan.FromMinutes(30), stoppingToken);
            }
        }
    }
}
