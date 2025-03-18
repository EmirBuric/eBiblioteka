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
    public class CitaonicaServis : BaseCRUDServis<CitaonicaDTO, CitaonicaSearchObject, Citaonica, CitaonicaUpsertRequest, CitaonicaUpsertRequest>, ICitaonicaServis
    {
        public CitaonicaServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Citaonica> AddFilter(CitaonicaSearchObject search, IQueryable<Citaonica> query)
        {
            if (!string.IsNullOrEmpty(search.NazivGTE))
            {
                query = query.Where(x => x.Naziv.ToLower().StartsWith(search.NazivGTE));
            }

            return query;
        }
    }
}
