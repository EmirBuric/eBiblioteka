using eBiblioteka.Modeli.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi
{
    public interface ICRUDServis<TModel,TSearch,TInsert,TUpdate>:
        IServis<TModel,TSearch> 
        where TModel:class
        where TSearch : BaseSearchObject
    {
        TModel Insert(TInsert insert);
        TModel Update(int id, TUpdate update);
    }
}
