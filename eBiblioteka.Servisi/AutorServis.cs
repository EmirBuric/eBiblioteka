using eBiblioteka.Modeli;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Database;
using MapsterMapper;


namespace eBiblioteka.Servisi
{
    public class AutorServis : BaseCRUDServis<Modeli.Autor, AutorSearchObject, Database.Autor, AutorUpsertRequest, AutorUpsertRequest>,IAutorServis
    {
        public AutorServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Database.Autor> AddFilter(AutorSearchObject search, IQueryable<Database.Autor> query)
        {
            if (!string.IsNullOrEmpty(search?.ImeGTE) || !string.IsNullOrEmpty(search.PrezimeGTE)) 
            {
                query=query.Where(x=>x.Ime.ToLower().StartsWith(search.ImeGTE) 
                || x.Prezime.ToLower().StartsWith(search.PrezimeGTE));
            }
            return query;
        }

    }
}
