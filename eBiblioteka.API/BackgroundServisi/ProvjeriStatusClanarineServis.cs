
using eBiblioteka.Servisi.Interfaces;

namespace eBiblioteka.API.BackgroundServisi
{
    public class ProvjeriStatusClanarineServis : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;

        public ProvjeriStatusClanarineServis(IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            using var scope = _serviceProvider.CreateScope();
            var clanarinaServis = scope.ServiceProvider.GetRequiredService<IClanarinaServis>();
            while (!stoppingToken.IsCancellationRequested)
            {
                await clanarinaServis.ProvjeriValidnostClanarine();
                await Task.Delay(TimeSpan.FromHours(24), stoppingToken);
            }
        }
    }
}
