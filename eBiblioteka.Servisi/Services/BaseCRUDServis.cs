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

            await BeforeInsert(insert, entity);

            Context.Add(entity);

            await Context.SaveChangesAsync(cancellationToken);

            await AfterInsert(insert, entity);

            return Mapper.Map<TModel>(entity);
        }

        public virtual async Task BeforeInsert(TInsert insert, TDbEntity entity, CancellationToken cancellationToken = default)
        {

        }
        public virtual async Task AfterInsert(TInsert insert, TDbEntity entity, CancellationToken cancellationToken = default)
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

            await BeforeUpdate(update, entity);

            await Context.SaveChangesAsync(cancellationToken);

            await AfterUpdate(update, entity);

            return Mapper.Map<TModel>(entity);

        }

        public virtual async Task BeforeUpdate(TUpdate update, TDbEntity entity, CancellationToken cancellationToken = default)
        {

        }
        public virtual async Task AfterUpdate(TUpdate update, TDbEntity entity, CancellationToken cancellationToken = default)
        {

        }
    }
}
