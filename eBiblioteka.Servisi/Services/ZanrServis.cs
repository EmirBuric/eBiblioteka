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
    public class ZanrServis : BaseCRUDServis<ZanrDTO, ZanrSearchObject, Zanr, ZanrUpsertRequest, ZanrUpsertRequest>,IZanrServis
    {
        public ZanrServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Zanr> AddFilter(ZanrSearchObject search, IQueryable<Zanr> query)
        {
            if(!string.IsNullOrEmpty(search.NazivGTE))
            {
                query=query.Where(x=>x.Naziv.ToLower().StartsWith(search.NazivGTE));
            }
            return query;
        }

        public override void BeforeInsert(ZanrUpsertRequest insert, Zanr entity)
        {
            bool exists=Context.Zanrs.Any(x=>x.Naziv.ToLower()==insert.Naziv.ToLower());
            
            if (exists) 
            {
                throw new Exception("Zanr već postoji");
            }

            base.BeforeInsert(insert, entity);
        }
    }
}
