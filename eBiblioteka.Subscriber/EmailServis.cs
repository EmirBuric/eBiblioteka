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

        public void PosaljiEmail(string primateljEmail, string poruka)
        {
            var emailConfig = _configuration.GetSection("Email");
            var emailPoruka = new MimeMessage();

            var odEmail = Environment.GetEnvironmentVariable("odEmail");

            emailPoruka.From.Add(new MailboxAddress("Rezervacija u biblioteci",odEmail));
            emailPoruka.To.Add(new MailboxAddress("Korisnik",primateljEmail));
            emailPoruka.Subject = "Rezervacija potvrđena";
            emailPoruka.Body = new TextPart("plain")
            {
                Text = poruka
            };

            using var klijent = new SmtpClient();
            try
            {
                klijent.Connect(emailConfig["SmtpServer"], int.Parse(emailConfig["SmtpPort"]), false);
                var smtpSifra= Environment.GetEnvironmentVariable("smtpSifra");
                var smtpKorisnik = Environment.GetEnvironmentVariable("smtpKorisnik");
                klijent.Authenticate(smtpKorisnik, smtpSifra);

                klijent.Send(emailPoruka);
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
