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

        public override Autor Insert(AutorUpsertRequest insert)
        {
            return base.Insert(insert);
        }

        public override PagedResult<Autor> GetList([FromQuery] AutorSearchObject searchObject) 
        {
            return base.GetList(searchObject);
        }
    }
}
