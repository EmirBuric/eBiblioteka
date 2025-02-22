using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Servisi;
using Microsoft.AspNetCore.Mvc;

namespace eBiblioteka.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BaseCRUDController<TModel,TSearch,TInsert,TUpdate> :
        BaseController<TModel,TSearch> 
        where TModel : class
        where TSearch:BaseSearchObject
    {
        protected new ICRUDServis<TModel,TSearch,TInsert,TUpdate> _servis;

        public BaseCRUDController(ICRUDServis<TModel, TSearch, TInsert, TUpdate> servis):base(servis) 
        {
            _servis = servis;
        }

        [HttpPost]
        public virtual TModel Insert(TInsert insert) 
        {
            return _servis.Insert(insert);
        }

        [HttpPut("{id}")]
        public virtual TModel Update(int id,TUpdate update) 
        {
            return _servis.Update(id, update);
        }
    }
}
