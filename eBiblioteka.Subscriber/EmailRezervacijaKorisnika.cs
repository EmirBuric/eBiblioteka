using Microsoft.Extensions.Configuration;
using MimeKit;
using MailKit.Net.Smtp;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Org.BouncyCastle.Pqc.Crypto.Bike;
using RabbitMQ.Client.Exceptions;
using EasyNetQ;
using Newtonsoft.Json;
using eBiblioteka.Modeli.DTOs;

namespace eBiblioteka.Subscriber
{
    public class EmailRezervacijaKorisnika
    {
        private IChannel _channel;
        private readonly IConfiguration _configuration;
        private readonly EmailServis _emailServis;

        public EmailRezervacijaKorisnika(IConfiguration configuration, EmailServis emailServis)
        {
            _configuration = configuration;
            _emailServis = emailServis;

            Initialize().GetAwaiter().GetResult();
        }
        private async Task Initialize()
        {
            //var factory = new ConnectionFactory() { HostName = _configuration["RabbitMQ:HostName"] };
            var factory = new ConnectionFactory
            {
                HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost",
                Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
                UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest",
                Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest",
                VirtualHost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/"
            };
            const int maxRetries = 5;
            for (int retry = 0; retry < maxRetries; retry++)
            {
                try
                {
                    var connection = await factory.CreateConnectionAsync();
                    _channel = await connection.CreateChannelAsync();
                    Console.WriteLine("RabbitMQ spojen");
                    return;
                }
                catch (BrokerUnreachableException)
                {
                    Console.WriteLine($"RabbitMQ ne radi, pokušavam ponovo za 5 sekundi... (pokušaj {retry + 1})");
                    await Task.Delay(5000);
                }
            }

            throw new Exception("Nije bilo moguće se spojiti sa RabbitMQ nakon više pokušaja");
            //var connection = await factory.CreateConnectionAsync();
            //_channel = await connection.CreateChannelAsync();
        }

        public async Task PosaljiEmailAsync()
        {
            await _channel.QueueDeclareAsync(queue: _configuration["RabbitMQ:QueueName"],
                durable: false,
                exclusive: false,
                autoDelete: false,
                arguments: null);

            var consumer = new AsyncEventingBasicConsumer(_channel);

            consumer.ReceivedAsync += async (model, ea) =>
            {
                try
                {
                    var body = ea.Body.ToArray();
                    var json = Encoding.UTF8.GetString(body);

                    Console.WriteLine("[X] Primljeno {0}", json);

                    var poruka= JsonConvert.DeserializeObject<RezervacijaPorukaDTO>(json);

                    if (poruka != null && !string.IsNullOrEmpty(poruka.KorisnikEmail))
                    {
                        await ObradiPoruku(poruka);
                    }
                    else
                    {
                        Console.WriteLine("Neispravan format poruke ili nema email");
                    }

                }
                catch (Exception)
                {

                    throw;
                }
            };
            await _channel.BasicConsumeAsync(queue: _configuration["RabbitMQ:QueueName"],
                autoAck: true,
                consumer: consumer);
        }
        private async Task ObradiPoruku(RezervacijaPorukaDTO poruka)
        {
            string subject = "";
            string body = "";

            switch (poruka.TipPoruke) 
            {
                case "ODOBRENA":
                    subject = "Rezervacija je odobrena";
                    body = $@"
                        Poštovani/a {poruka.KorisnikIme} {poruka.KorisnikPrezime}
                        
                        Vaša rezervacija je odobrena!
                        
                        Detalji rezervacije:
                        - Knjiga: {poruka.NazivKnjige}
                        - Period: {poruka.DatumOd:dd.MM.yyyy} - {poruka.DatumDo:dd.MM.yyyy}
                        
                        Knjiga Vas očekuje u biblioteci.
                        
                        Pozdrav,
                        Vaša eBiblioteka
                        ";
                    break;
                case "OTKAZANA":
                    subject = "Rezervacija je otkazana";
                    body = $@"
                        Poštovani/a {poruka.KorisnikIme} {poruka.KorisnikPrezime}
                        
                        Žao nam je, li Vaša rezervacija je otkazana.
                        
                        Detalji rezervacije:
                        - Knjiga: {poruka.NazivKnjige}
                        - Period: {poruka.DatumOd:dd.MM.yyyy} - {poruka.DatumDo:dd.MM.yyyy}
                        
                        Molimo kontaktirajte nas za više informacija.
                        
                        Pozdrav,
                        Vaša eBiblioteka
                        ";
                    break;
            }
            if (!string.IsNullOrEmpty(subject) && !string.IsNullOrEmpty(body)) 
            {
                await _emailServis.PosaljiEmail(poruka.KorisnikEmail,subject, body);
            }
        }
    }
}
