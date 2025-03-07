using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Encodings.Web;

namespace eBiblioteka.API.Auth
{
    public class BasicAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        private readonly IKorisniciServis _korisniciServis;

        public BasicAuthenticationHandler(IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger, UrlEncoder encoder, ISystemClock clock, IKorisniciServis korisniciServis) : base(options, logger, encoder, clock)
        {
            _korisniciServis = korisniciServis;
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            if (!Request.Headers.ContainsKey("Authorization"))
            {
                return AuthenticateResult.Fail("Missing header");
            }

            var authHeader = AuthenticationHeaderValue.Parse(Request.Headers["Authorization"]);
            var credentialBytes = Convert.FromBase64String(authHeader.Parameter);
            var credentials = Encoding.UTF8.GetString(credentialBytes).Split(":");

            var username = credentials[0];
            var password = credentials[1];

            var user = _korisniciServis.Login(username, password);

            if (user == null)
            {
                return AuthenticateResult.Fail("Auth failed");
            }
            else
            {
                var claims = new List<Claim>()
                {
                    new Claim(ClaimTypes.Name,user.Ime),
                    new Claim(ClaimTypes.NameIdentifier,user.KorisnickoIme)
                };

                foreach (var uloga in user.KorisnikUlogas)
                {
                    claims.Add(new Claim(ClaimTypes.Role, uloga.Uloga.Naziv));
                }
                var identity = new ClaimsIdentity(claims, Scheme.Name);

                var principal = new ClaimsPrincipal(identity);

                var ticket = new AuthenticationTicket(principal, Scheme.Name);

                return AuthenticateResult.Success(ticket);
            }
        }
    }
}
