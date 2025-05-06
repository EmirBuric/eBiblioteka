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
                UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME"),
                Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD"),
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
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                Console.WriteLine("[X] Primljeno {0}", message);
                var email = ExtractEmailFromMessage(message);
                if (!string.IsNullOrEmpty(email))
                {
                    _emailServis.PosaljiEmail(email, "Vaša rezervacija je prihvaćena");
                }
            };
            await _channel.BasicConsumeAsync(queue: _configuration["RabbitMQ:QueueName"],
                autoAck: true,
                consumer: consumer);
        }
        private string ExtractEmailFromMessage(string message)
        {
            var parts = message.Split(' ');
            return parts.Length > 3 ? parts[3] : string.Empty;
        }
    }
}
