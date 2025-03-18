using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Database;
using eBiblioteka.Servisi.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Services
{
    public class TerminServis : BaseCRUDServis<TerminDTO, TerminSearchObject, Termin, TerminUpsertRequest, TerminUpsertRequest>, ITerminServis
    {
        public TerminServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Termin> AddFilter(TerminSearchObject search, IQueryable<Termin> query)
        {
            if (search.CitaonicaId != null) 
            {
                query=query.Where(x=>x.CitaonicaId == search.CitaonicaId);
            }

            if (search.JeRezervisan != null) 
            {
                query=query.Where(x=>x.JeRezervisan == search.JeRezervisan);
            }

            if(search.DatumGTE!=null)
            {
                query=query.Where(x=>x.Datum >= search.DatumGTE);
            }

            if (search.DatumLTE != null)
            {
                query = query.Where(x => x.Datum >= search.DatumLTE);
            }
            if (!string.IsNullOrEmpty(search.ImePrezimeGTE))
            {
                query = query.Include(x => x.Korisnik).Where(x => (x.Korisnik.Ime + " " + x.Korisnik.Prezime).ToLower().StartsWith(search.ImePrezimeGTE));
            }

            return query;
        }

        public override IQueryable<Termin> AddInclude(IQueryable<Termin> query, TerminSearchObject? search = null)
        {
            query = query.Include("Korisnik");

            return base.AddInclude(query, search);
        }

        public override async Task<Termin> AddIncludeId(IQueryable<Termin> query, int id)
        {
            query = query.Include("Korisnik");

            var entity= await query.FirstOrDefaultAsync(x => x.TerminId == id);

            return entity;
        }

        public override Task BeforeInsert(TerminUpsertRequest insert, Termin entity, CancellationToken cancellationToken = default)
        {
            entity.JeRezervisan=false;
            return base.BeforeInsert(insert, entity, cancellationToken);
        }

        public override Task BeforeUpdate(TerminUpsertRequest update, Termin entity, CancellationToken cancellationToken = default)
        {
            entity.JeRezervisan = false;
            return base.BeforeUpdate(update, entity, cancellationToken);
        }
    }
}
