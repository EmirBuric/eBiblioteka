using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Servisi.Database;
using eBiblioteka.Servisi.Interfaces;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Services
{
    public class BaseCRUDServis<TModel, TSearch, TDbEntity, TInsert, TUpdate> :
        BaseServis<TModel, TSearch, TDbEntity>,
        ICRUDServis<TModel, TSearch, TInsert, TUpdate>
        where TModel : class where TDbEntity : class, new()
        where TSearch : BaseSearchObject
    {
        public BaseCRUDServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }



        public async Task<TModel> Insert(TInsert insert, CancellationToken cancellationToken = default)
        {
            TDbEntity entity = Mapper.Map<TDbEntity>(insert);

            BeforeInsert(insert, entity);

            Context.Add(entity);
            await Context.SaveChangesAsync(cancellationToken);

            AfterInsert(insert, entity);

            return Mapper.Map<TModel>(entity);
        }

        public virtual void BeforeInsert(TInsert insert, TDbEntity entity)
        {

        }
        public virtual void AfterInsert(TInsert insert, TDbEntity entity)
        {

        }

        public async Task<TModel> Update(int id, TUpdate update, CancellationToken cancellationToken = default)
        {
            var entity = await Context.Set<TDbEntity>().FindAsync(id, cancellationToken);

            if (entity == null)
            {
                throw new Exception("Objekat sa ovim id-om ne postoji!");
            }

            Mapper.Map(update, entity);

            BeforeUpdate(update, entity);

            await Context.SaveChangesAsync(cancellationToken);

            AfterUpdate(update, entity);

            return Mapper.Map<TModel>(entity);

        }

        public virtual void BeforeUpdate(TUpdate update, TDbEntity entity)
        {

        }
        public virtual void AfterUpdate(TUpdate update, TDbEntity entity)
        {

        }
    }
}
