using eBiblioteka.Modeli;
using eBiblioteka.Modeli.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Interfaces
{
    public interface IServis<TModel, TSearch> where TSearch : BaseSearchObject
    {
        public Task<PagedResult<TModel>> GetPaged(TSearch search, CancellationToken cancellationToken = default);
        public Task<TModel> GetById(int id, CancellationToken cancellationToken = default);
    }
}
