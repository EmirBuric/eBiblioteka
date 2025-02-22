using eBiblioteka.Modeli;
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
    public class BaseServis<TModel, TSearch, TDbEntity> :
        IServis<TModel, TSearch> where TModel : class 
        where TDbEntity : class, new()
        where TSearch : BaseSearchObject
    {
        public Db180105Context Context { get; }

        public BaseServis(Db180105Context context,IMapper mapper)
        {
            Context = context;
            Mapper = mapper;
        }

        public IMapper Mapper { get; }

        public PagedResult<TModel> GetPaged(TSearch search)
        {
            List<TModel> res = new List<TModel>();

            var query= Context.Set<TDbEntity>().AsQueryable();

            query=AddFilter(search, query);

            int count= query.Count();

            if(search?.Page.HasValue==true &&
                search?.PageSize.HasValue==true &&
                (search?.RetrieveAll.HasValue==false || 
                search?.RetrieveAll == null)) 
            {
                query=query.Skip((search.Page.Value-1)* search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = query.ToList();

            res = Mapper.Map(list, res);

            PagedResult<TModel> pagedResult = new PagedResult<TModel>();
            pagedResult.ResultList = res;
            pagedResult.Count = count;

            return pagedResult;

        }
        public virtual IQueryable<TDbEntity> AddFilter(TSearch search, IQueryable<TDbEntity> query)
        {
            return query;
        }

        public TModel GetById(int id)
        {
            var entity = Context.Set<TDbEntity>().Find(id);

            if(entity!=null)
            {
                return Mapper.Map<TModel>(entity);
            }
            else
            {
                return null;
            }
        }
    }
}
