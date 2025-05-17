using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Authorization;

namespace eBiblioteka.API.Controllers
{
    public class ZanrController : BaseCRUDController<ZanrDTO, ZanrSearchObject, ZanrUpsertRequest, ZanrUpsertRequest>
    {
        public ZanrController(IZanrServis servis) : base(servis)
        {
        }
    }
}
