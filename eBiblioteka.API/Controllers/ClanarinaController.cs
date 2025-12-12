using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    public class ClanarinaController : BaseCRUDController<ClanarinaDTO, ClanarinaSearchObject, ClanarinaUpsertRequest, ClanarinaUpsertRequest>
    {
        public ClanarinaController(IClanarinaServis servis) : base(servis)
        {
        }

        [HttpGet("ByKorisnikId")]
        public async Task<ClanarinaDTO> GetClanarinaByKorisnikId(int korisnikId)
        {
            return await (_servis as IClanarinaServis).GetClanarinaByKorisnikId(korisnikId);
        }

        [HttpGet("GetMjesecniIzvjestaj")]
        public async Task<ClanarinaIzvjestajDTO> GetMjesecniIzvjestaj(int mjesec, int godina)
        {
            return await (_servis as IClanarinaServis).GetMjesecniIzvjestaj(mjesec, godina);
        }
    }
}
