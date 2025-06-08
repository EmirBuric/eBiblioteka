using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Database;
using eBiblioteka.Servisi.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Services
{
    public class KorisnikIzabranaKnjigServis : BaseCRUDServis<KorisnikIzabranaKnjigaDTO, KorisnikIzabranaKnjigaSearchObject, KorisnikIzabranaKnjiga, KorisnikIzabranaKnjigaUpsertRequest, KorisnikIzabranaKnjigaUpsertRequest>, IKorisnikIzabranaKnjigaServis
    {
        public KorisnikIzabranaKnjigServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<KorisnikIzabranaKnjiga> AddFilter(KorisnikIzabranaKnjigaSearchObject search, IQueryable<KorisnikIzabranaKnjiga> query)
        {
            if (search.KorisnikIdGTE != null)
            {
                query = query.Where(x => x.KorisnikId == search.KorisnikIdGTE);
            }

            if (search.KnjigaIdGTE != null)
            {
                query = query.Where(x => x.KnjigaId == search.KnjigaIdGTE);
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
            if (search.IsChecked != null)
            {
                query = query.Where(x => x.IsChecked == search.IsChecked);
            }


            return query;
        }

        public override IQueryable<KorisnikIzabranaKnjiga> AddInclude(IQueryable<KorisnikIzabranaKnjiga> query, KorisnikIzabranaKnjigaSearchObject? search = null)
        {
            query = query.Include("Korisnik");
            query = query.Include("Knjiga");

            return base.AddInclude(query, search);
        }

        public override Task BeforeInsert(KorisnikIzabranaKnjigaUpsertRequest insert, KorisnikIzabranaKnjiga entity, CancellationToken cancellationToken = default)
        {
            if (insert.DatumVracanja == null)
                entity.DatumVracanja = insert.DatumRezervacije.AddDays(7);
            else
                entity.DatumVracanja = insert.DatumVracanja.Value;

            entity.IsChecked = true;

            return base.BeforeInsert(insert, entity, cancellationToken);
        }

        public override async Task<KorisnikIzabranaKnjiga> AddIncludeId(IQueryable<KorisnikIzabranaKnjiga> query, int id)
        {
            query = query.Include("Korisnik");
            query = query.Include("Knjiga");
            var entity = await query.FirstOrDefaultAsync(x => x.KorisnikIzabranaKnjigaId == id);
            return entity;
        }

        public override Task BeforeUpdate(KorisnikIzabranaKnjigaUpsertRequest update, KorisnikIzabranaKnjiga entity, CancellationToken cancellationToken = default)
        {
            if (update.DatumVracanja == null)
                entity.DatumVracanja = update.DatumRezervacije.AddDays(7);
            else
                entity.DatumVracanja = update.DatumVracanja.Value;

            entity.IsChecked = true;

            return base.BeforeUpdate(update, entity, cancellationToken);
        }

        public async Task UpdateIsCheckedList(List<int> isCheckedIdsList)
        {
            if (!isCheckedIdsList.IsNullOrEmpty())
            {
                var knjige = await Context.KorisnikIzabranaKnjigas
                    .Where(x => isCheckedIdsList.Contains(x.KorisnikIzabranaKnjigaId))
                    .ToListAsync();

                foreach (var knjiga in knjige)
                {
                    knjiga.IsChecked = false;
                }
                await Context.SaveChangesAsync();
            }
        }

        public async Task UpdateIsChecked(int isCheckedId)
        {
            var knjiga= await Context.KorisnikIzabranaKnjigas.FirstOrDefaultAsync(x=>x.KorisnikIzabranaKnjigaId == isCheckedId);
            
            if (knjiga == null)
                return;
            
            knjiga.IsChecked=false;
            await Context.SaveChangesAsync();
        }
    }
}
