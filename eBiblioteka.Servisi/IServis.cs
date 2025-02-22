using eBiblioteka.Modeli;
using eBiblioteka.Modeli.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi
{
    public interface IServis<TModel,TSearch> where TSearch:BaseSearchObject
    {
        public PagedResult<TModel> GetPaged(TSearch search);
        public TModel GetById(int id);
    }
}
