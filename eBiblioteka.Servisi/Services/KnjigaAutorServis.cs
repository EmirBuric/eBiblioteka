using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
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
    public class KnjigaAutorServis : BaseCRUDServis<KnjigaAutorDTO, KnjigaAutorSearchObject, KnjigaAutor, KnjigaAutorUpsertRequest, KnjigaAutorUpsertRequest>,IKnjigaAutoriServis
    {
        public KnjigaAutorServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<KnjigaAutor> AddFilter(KnjigaAutorSearchObject search, IQueryable<KnjigaAutor> query)
        {
            if (search.AutorId != null) 
            {
                query= query.Where(x=>x.AutorId == search.AutorId);
            }
            if (search.KnjigaId != null) 
            {
                query=query.Where(x=>x.KnjigaId == search.KnjigaId);
            }
            return query;
        }
    }
}
