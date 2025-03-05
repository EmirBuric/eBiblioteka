using eBiblioteka.Modeli;
using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    public class AutorController : BaseCRUDController<AutorDTO, AutorSearchObject, AutorUpsertRequest, AutorUpsertRequest>
    {
        public AutorController(IAutorServis servis) : base(servis)
        {
        }

        public override Task<AutorDTO> Insert(AutorUpsertRequest insert, CancellationToken cancellationToken = default)
        {
            return base.Insert(insert,cancellationToken);
        }

        public override Task<PagedResult<AutorDTO>> GetList([FromQuery] AutorSearchObject searchObject, CancellationToken cancellationToken=default) 
        {
            return base.GetList(searchObject,cancellationToken);
        }
    }
}
