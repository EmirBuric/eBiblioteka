// See https://aka.ms/new-console-template for more information
using EasyNetQ;
using eBiblioteka.Modeli.Messages;

Console.WriteLine("Hello, World!");

var bus = RabbitHutch.CreateBus("host=localhost");

await bus.PubSub.SubscribeAsync<AutoriSearched>("console_printer", msg =>
{
    Console.WriteLine($"Korisnik pretrazio ove autore: {msg.Autori.ImeGTE } { msg.Autori.PrezimeGTE}");
});

await bus.PubSub.SubscribeAsync<AutoriSearched>("mail_sender", msg =>
{
    Console.WriteLine($"Saljemo Email {msg.Autori.ImeGTE} {msg.Autori.PrezimeGTE}");
    //todo send email
});

Console.WriteLine("Listening for messages, press <return> to close");
Console.ReadLine();