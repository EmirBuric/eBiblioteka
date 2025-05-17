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
    }
}
