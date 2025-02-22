using eBiblioteka.Modeli;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Servisi;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BaseController<TModel,TSearch>:ControllerBase where TSearch : BaseSearchObject
    {
        private readonly IServis<TModel, TSearch> _servis;

        public BaseController(IServis<TModel, TSearch> servis)
        {
            _servis = servis;
        }

        [HttpGet]
        public virtual PagedResult<TModel> GetList([FromQuery] TSearch searchObject) 
        {
            return _servis.GetPaged(searchObject);
        }

        [HttpGet("{id}")]
        public virtual TModel GetById(int id)
        {
            return _servis.GetById(id);
        }

    }
}
