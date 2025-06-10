using MailKit.Net.Smtp;
using Microsoft.Extensions.Configuration;
using MimeKit;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Subscriber
{
    public class EmailServis
    {
        private readonly IConfiguration _configuration;
        public EmailServis(IConfiguration configuration) 
        {
            _configuration = configuration;
        }

        public async Task PosaljiEmail(string primateljEmail, string subject, string body)
        {
            var emailConfig = _configuration.GetSection("Email");
            var emailPoruka = new MimeMessage();

            var odEmail = Environment.GetEnvironmentVariable("FromEmail");

            emailPoruka.From.Add(new MailboxAddress("eBiblioteka",odEmail));
            emailPoruka.To.Add(new MailboxAddress("Korisnik",primateljEmail));
            emailPoruka.Subject = subject;
            emailPoruka.Body = new TextPart("plain")
            {
                Text = body
            };

            Console.WriteLine(emailPoruka);

            using var klijent = new SmtpClient();
            try
            {
                await klijent.ConnectAsync(emailConfig["SmtpServer"], int.Parse(emailConfig["SmtpPort"]), false);
                var smtpSifra= Environment.GetEnvironmentVariable("SmtpPass");
                var smtpKorisnik = Environment.GetEnvironmentVariable("SmtpUser");
                await klijent.AuthenticateAsync(smtpKorisnik, smtpSifra);

                await klijent.SendAsync(emailPoruka);
                Console.WriteLine("Email uspjesno poslan");
            }
            catch(Exception ex)
            {
                Console.WriteLine($"Dogodila se grešla pri slanju maila za {primateljEmail}: {ex.Message}");
            }
            finally
            {
                klijent.Disconnect(true);
                klijent.Dispose();
            }
        }
    }
}
