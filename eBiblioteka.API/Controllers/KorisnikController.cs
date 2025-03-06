using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    public class KorisnikController : BaseCRUDController<KorisniciDTO, KorisnikSearchObject, KorisnikInsertRequest, KorisnikUpdateRequest>
    {
        public KorisnikController(IKorisniciServis servis) : base(servis)
        {
        }

        [HttpPost("login")]
        public KorisniciDTO Login(string korisnickoIme, string sifra)
        {
            return (_servis as IKorisniciServis).Login(korisnickoIme, sifra);
        }
    }
}
