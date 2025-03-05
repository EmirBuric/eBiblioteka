using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Servisi.Interfaces;
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
        public virtual Task<TModel> Insert(TInsert insert, CancellationToken cancellationToken=default) 
        {
            return _servis.Insert(insert,cancellationToken);
        }

        [HttpPut("{id}")]
        public virtual Task<TModel> Update(int id,TUpdate update,CancellationToken cancellationToken=default) 
        {
            return _servis.Update(id, update,cancellationToken);
        }
    }
}
