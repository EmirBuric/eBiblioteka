using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    public class KorisnikController : BaseCRUDController<KorisniciDTO, KorisnikSearchObject, KorisnikInsertRequest, KorisnikUpdateRequest>
    {
        public KorisnikController(IKorisniciServis servis) : base(servis)
        {
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public KorisniciDTO Login(string korisnickoIme, string sifra)
        {
            return (_servis as IKorisniciServis).Login(korisnickoIme, sifra);
        }

        [AllowAnonymous]
        public override Task<KorisniciDTO> Insert(KorisnikInsertRequest insert, CancellationToken cancellationToken = default)
        {
            return base.Insert(insert, cancellationToken);
        }

        [HttpPost("Delete/{id}")]
        public async Task Ban(int id) 
        {
            await (_servis as IKorisniciServis).Ban(id);
        }

        [HttpGet("Uloga")]
        public async Task<string?> GetTrenutnaUloga()
        {
            return await (_servis as IKorisniciServis).GetTrenutnaUloga();
        }

        [HttpGet("TrenutniId")]
        public async Task<int?> GetTrenutniId()
        {
            return await (_servis as IKorisniciServis).GetTrenutniId();
        }
    }
}
