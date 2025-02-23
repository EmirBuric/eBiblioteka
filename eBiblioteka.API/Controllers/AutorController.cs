using eBiblioteka.Modeli;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    public class AutorController : BaseCRUDController<Modeli.Autor, AutorSearchObject, AutorUpsertRequest, AutorUpsertRequest>
    {
        public AutorController(IAutorServis servis) : base(servis)
        {
        }

        public override Task<Autor> Insert(AutorUpsertRequest insert, CancellationToken cancellationToken = default)
        {
            return base.Insert(insert,cancellationToken);
        }

        public override Task<PagedResult<Autor>> GetList([FromQuery] AutorSearchObject searchObject, CancellationToken cancellationToken=default) 
        {
            return base.GetList(searchObject,cancellationToken);
        }
    }
}
