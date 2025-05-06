// See https://aka.ms/new-console-template for more information
using EasyNetQ;
using eBiblioteka.Modeli.Messages;
using eBiblioteka.Subscriber;
using Microsoft.Extensions.Configuration;

/*Console.WriteLine("Hello, World!");

var bus = RabbitHutch.CreateBus("host=localhost");

await bus.PubSub.SubscribeAsync<AutoriSearched>("console_printer", msg =>
{
    Console.WriteLine($"Korisnik pretrazio ove autore: {msg.Autori.ImeGTE } { msg.Autori.PrezimeGTE}");
});

await bus.PubSub.SubscribeAsync<AutoriSearched>("mail_sender", msg =>
{
    Console.WriteLine($"Saljemo Email {msg.Autori.ImeGTE} {msg.Autori.PrezimeGTE}");
    //todo send email
});*/

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