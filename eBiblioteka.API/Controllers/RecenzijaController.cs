using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    public class RecenzijaController : BaseCRUDController<RecenzijaDTO, RecenzijaSearchObject, RecenzijaUpsertRequest, RecenzijaUpsertRequest>
    {
        public RecenzijaController(IRecenzijaServis servis) : base(servis)
        {
        }

        [HttpPost("Odbij/{id}")]
        public async Task Odbij(int id)
        {
            await (_servis as IRecenzijaServis).Odbij(id);
        }

        [HttpPost("Prihvati/{id}")]
        public async Task Prihvati(int id)
        {
            await (_servis as IRecenzijaServis).Prihvati(id);
        }
    }
}
