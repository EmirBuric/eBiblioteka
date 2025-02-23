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
        public virtual Task<PagedResult<TModel>> GetList([FromQuery] TSearch searchObject, CancellationToken cancellationToken=default) 
        {
            return _servis.GetPaged(searchObject,cancellationToken);
        }

        [HttpGet("{id}")]
        public virtual Task<TModel> GetById(int id,CancellationToken cancellationToken=default)
        {
            return _servis.GetById(id,cancellationToken);
        }

    }
}
