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
    public class RezervacijaServis : BaseCRUDServis<RezervacijaDTO, RezervacijaSearchObject, Rezervacija, RezervacijaUpsertRequest, RezervacijaUpsertRequest>, IRezervacijaServis
    {
        public RezervacijaServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Rezervacija> AddFilter(RezervacijaSearchObject search, IQueryable<Rezervacija> query)
        {
            if (search.KorisnikId != null) 
            {
                query= query.Where(x=>x.KorisnikId==search.KorisnikId);
            }

            if (search.KnjigaId != null) 
            {
                query=query.Where(x=>x.KnjigaId==search.KnjigaId);
            }

            if (search.DatumRezervacijeGTE != null)
            {
                query = query.Where(x => x.DatumRezervacije >= search.DatumRezervacijeGTE);
            }

            if (search.DatumVracanjaGTE != null)
            {
                query = query.Where(x => x.DatumVracanja >= search.DatumVracanjaGTE);
            }

            if (!string.IsNullOrEmpty(search.NazivGTE))
            {
                query = query.Include(x => x.Knjiga).Where(x => x.Knjiga.Naziv.ToLower().StartsWith(search.NazivGTE));
            }

            if (!string.IsNullOrEmpty(search.ImePrezimeGTE))
            {
                query = query.Include(x => x.Korisnik).Where(x => (x.Korisnik.Ime + " " + x.Korisnik.Prezime).ToLower().StartsWith(search.ImePrezimeGTE));
            }

            return query;
        }

        public override IQueryable<Rezervacija> AddInclude(IQueryable<Rezervacija> query, RezervacijaSearchObject? search = null)
        {
            query = query.Include("Korisnik");
            query = query.Include("Knjiga");

            return base.AddInclude(query, search);
        }

        public override Task BeforeInsert(RezervacijaUpsertRequest insert, Rezervacija entity, CancellationToken cancellationToken = default)
        {
            entity.Odobrena=false;
            entity.Pregledana=false;

            if (insert.DatumVracanja == null)
                entity.DatumVracanja = insert.DatumRezervacije.AddDays(7);
            else
                entity.DatumVracanja = insert.DatumVracanja.Value;

            return base.BeforeInsert(insert, entity, cancellationToken);
        }

        public override Task BeforeUpdate(RezervacijaUpsertRequest update, Rezervacija entity, CancellationToken cancellationToken = default)
        {
            entity.Odobrena = false;
            entity.Pregledana = false;

            if (update.DatumVracanja == null)
                entity.DatumVracanja = update.DatumRezervacije.AddDays(7);
            else
                entity.DatumVracanja = update.DatumVracanja.Value;


            return base.BeforeUpdate(update, entity, cancellationToken);
        }

        public override async Task<Rezervacija> AddIncludeId(IQueryable<Rezervacija> query, int id)
        {
            query = query.Include("Korisnik");
            query = query.Include("Knjiga");
            var entity = await query.FirstOrDefaultAsync(x => x.RezervacijaId == id);
            return entity;

        }

    }
}
