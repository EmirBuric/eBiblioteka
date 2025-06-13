using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    public class KnjigaController : BaseCRUDController<KnjigaDTO, KnjigaSearchObject, KnjigaInsertRequest, KnjigaUpdateRequest>
    {
        public KnjigaController(IKnjigaServis servis) : base(servis)
        {
        }

        [HttpPost("Delete/{id}")]
        public async Task Delete(int id)
        {
            await (_servis as IKnjigaServis).Delete(id);
        }

        [HttpPost("KnjigaDana/{id}")]
        public async Task KnjigaDana(int id)
        {
            await (_servis as IKnjigaServis).SelectKnjigaDana(id);
        }

        [HttpPost("Preporuka")]
        public async Task SelectPreporucenaKnjiga(List<int> ids)
        {
            await (_servis as IKnjigaServis).SelectPreporucenaKnjiga(ids);
        }

        [HttpGet("Kalendar/{id}")]
        public async Task<DostupnostKnjigeDTO> GetDostupnostZaPeriod(
        int id,
        [FromQuery] DateTime datumOd,
        [FromQuery] DateTime datumDo)
        {
            return await (_servis as IKnjigaServis).GetDostupnostZaPeriod(id, datumOd, datumDo);
        }

        [HttpGet("Izvjestaj/{id}")]
        public async Task<KnjigaIzvjestajDTO> GetKnjigaIzvjestaj(
        int id,
        [FromQuery] DateTime datumOd,
        [FromQuery] DateTime datumDo)
        {
            return await (_servis as IKnjigaServis).GetKnjigaIzvjestaj(id, datumOd, datumDo);
        }
    }
}
