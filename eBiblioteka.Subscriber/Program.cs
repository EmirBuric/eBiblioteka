// See https://aka.ms/new-console-template for more information
using EasyNetQ;
using eBiblioteka.Modeli.Messages;
using eBiblioteka.Subscriber;
using Microsoft.Extensions.Configuration;

var builder = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json")
    .AddEnvironmentVariables();

var configuration= builder.Build();

var emailServis = new EmailServis(configuration);

var emailRezervacijaKorisnika= new EmailRezervacijaKorisnika(configuration,emailServis);
await emailRezervacijaKorisnika.PosaljiEmailAsync();


Console.WriteLine("Listening for messages, press <return> to close");
await Task.Delay(Timeout.Infinite);