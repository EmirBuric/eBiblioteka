using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Servisi.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi
{
    public class BaseCRUDServis<TModel, TSearch, TDbEntity, TInsert, TUpdate> : 
        BaseServis<TModel, TSearch, TDbEntity>,
        ICRUDServis<TModel,TSearch,TInsert,TUpdate> 
        where TModel : class where TDbEntity : class,new()
        where TSearch : BaseSearchObject
    {
        public BaseCRUDServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

    

        public TModel Insert(TInsert insert)
        {
            TDbEntity entity = Mapper.Map<TDbEntity>(insert);

            BeforeInsert(insert, entity);

            Context.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }

        public virtual void BeforeInsert(TInsert insert, TDbEntity entity)
        {

        }

        public TModel Update(int id, TUpdate update)
        {
            var entity = Context.Set<TDbEntity>().Find(id);

            if (entity == null)
            {
                throw new Exception("Objekat sa ovim id-om ne postoji!");
            }

            Mapper.Map(update, entity);

            BeforeUpdate(update, entity);

            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);

        }

        public virtual void BeforeUpdate(TUpdate update, TDbEntity entity)
        {
 
        }
    }
}
