using eBiblioteka.Modeli.DTOs;
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
    public class UlogaServis : BaseServis<UlogaDTO, UlogaSearchObject, Uloga>,IUlogaServis
    {
        public UlogaServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Uloga> AddFilter(UlogaSearchObject search, IQueryable<Uloga> query)
        {
            if (!string.IsNullOrEmpty(search.NazivGTE)) 
            {
                query=query.Where(x=>x.Naziv.ToLower().StartsWith(search.NazivGTE));
            }
            return query;
        }
    }
}
