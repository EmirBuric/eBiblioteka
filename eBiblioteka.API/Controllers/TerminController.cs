using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    public class TerminController : BaseCRUDController<TerminDTO, TerminSearchObject, TerminUpsertRequest, TerminUpsertRequest>
    {
        public TerminController(ITerminServis servis) : base(servis)
        {
        }

        [HttpPut("Rezervisi")]
        public async Task Rezervisi(RezervisiTerminRequest req)
        {
            await (_servis as ITerminServis).Rezervisi(req);
        }

        [HttpPut("Otkazi")]
        public async Task Otkazi(int terminId)
        {
            await (_servis as ITerminServis).Otkazi(terminId);
        }

    }
}
