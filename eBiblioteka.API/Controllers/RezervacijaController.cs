using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    public class RezervacijaController : BaseCRUDController<RezervacijaDTO, RezervacijaSearchObject, RezervacijaUpsertRequest, RezervacijaUpsertRequest>
    {
        public RezervacijaController(IRezervacijaServis servis) : base(servis)
        {
        }

        [HttpPut("PortvrdiRezervaciju")]
        public async Task PotvrdiRezervaciju(int id, bool potvrda)
        {
            await (_servis as IRezervacijaServis).PotvrdiRezervaciju(id, potvrda);
        }
    }
}
