
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.BackgroundServisi
{
    public class KreirajTerminServis : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        public KreirajTerminServis(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            using var scope = _serviceProvider.CreateScope();
            var terminService = scope.ServiceProvider.GetRequiredService<ITerminServis>();
            while (!stoppingToken.IsCancellationRequested)
            {
                await terminService.GenerisiTermine();
                await Task.Delay(TimeSpan.FromHours(24), stoppingToken);
            }
        }
    }
}
