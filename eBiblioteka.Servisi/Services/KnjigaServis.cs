using Azure.Core;
using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.Exceptions;
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
    public class KnjigaServis : BaseCRUDServis<KnjigaDTO, KnjigaSearchObject, Knjiga, KnjigaInsertRequest, KnjigaUpdateRequest>, IKnjigaServis
    {
        public KnjigaServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Knjiga> AddFilter(KnjigaSearchObject search, IQueryable<Knjiga> query)
        {
            query= query.Where(x=>x.IsDeleted==false);

            if (!string.IsNullOrEmpty(search.NazivGTE))
            {
                query = query.Where(x => x.Naziv.ToLower().StartsWith(search.NazivGTE));
            }

            if (search.GodinaIzdanjaGTE != null)
            {
                query = query.Where(x => x.GodinaIzdanja >= search.GodinaIzdanjaGTE);
            }

            if (search.GodinaIzdanjaLTE != null)
            {
                query = query.Where(x => x.GodinaIzdanja <= search.GodinaIzdanjaLTE);
            }

            if (search.ZanrId != null)
            {
                query = query.Where(x => x.ZanrId == search.ZanrId);
            }

            if (search.KolicinaGTE != null)
            {
                query = query.Where(x => x.Kolicina >= search.KolicinaGTE);
            }

            if (!string.IsNullOrEmpty(search.Autor))
            {
                query = query.Include(x => x.KnjigaAutors)
                    .ThenInclude(x => x.Autor)
                    .Where(x =>
                    (x.KnjigaAutors.Where(
                        y => (y.Autor.Ime + " " + y.Autor.Prezime).ToLower().StartsWith(search.Autor)
                        )).Count() > 0);
            }
            if(search.KnjigaDana!=null)
            {
                query=query.Where(x=>x.KnjigaDana==search.KnjigaDana);
            }

            return query;
        }

        public override async Task BeforeInsert(KnjigaInsertRequest insert, Knjiga entity, CancellationToken cancellationToken = default)
        {
            if (insert.Kolicina == 0)
            {
                entity.Dostupna = false;
            }

        }

        public override async Task AfterInsert(KnjigaInsertRequest insert, Knjiga entity, CancellationToken cancellationToken = default)
        {
            if (insert?.Autori != null)
            {
                foreach (var autorId in insert.Autori)
                {
                    Context.KnjigaAutors.Add(new KnjigaAutor
                    {
                        AutorId = autorId,
                        KnjigaId = entity.KnjigaId,
                    });
                }

                await Context.SaveChangesAsync(cancellationToken);
            }
        }

        public override async Task BeforeUpdate(KnjigaUpdateRequest update, Knjiga entity, CancellationToken cancellationToken = default)
        {

            if (update.Kolicina == 0)
            {
                entity.Dostupna = false;
            }
            if (update?.Autori != null)
            {
                var knjigaAutori = await Context
               .KnjigaAutors
               .Where(x => x.KnjigaId == entity.KnjigaId)
               .ToListAsync(cancellationToken);

                var noviAutori = update
                    .Autori
                    .Where(x => !knjigaAutori.Select(x => x.AutorId).Contains(x)).ToList();

                var nepotrebniAutori = knjigaAutori
                    .Where(x => !update.Autori.Contains((int)x.AutorId)).ToList();

                foreach (var x in noviAutori)
                {
                    await Context.KnjigaAutors.AddAsync(new KnjigaAutor
                    {
                        AutorId = x,
                        KnjigaId = entity.KnjigaId,
                    });
                }

                foreach (var x in nepotrebniAutori)
                {
                    Context.KnjigaAutors.Remove(x);
                }

                await Context.SaveChangesAsync();
            }
            else
            {
                throw new UserException("Autori moraju imati vrijednost!");
            }
        }


        public async Task Delete(int id)
        {
            var knjiga= await Context.Knjigas.FirstOrDefaultAsync(x => x.KnjigaId == id);

            if (knjiga == null)
            {
                throw new UserException("Nemoguće pronaći knjigu sa ovim Id-om");
            }

            knjiga.IsDeleted = true;
            knjiga.VrijemeBrisanja=DateTime.Now;
            Context.Update(knjiga);

            await Context.SaveChangesAsync();
        }

        public async Task SelectKnjigaDana(int id)
        {
            var staraKnjigaDana = await Context.Knjigas.FirstOrDefaultAsync(x=>x.KnjigaDana==true);
            
            if (staraKnjigaDana != null)
            {
                staraKnjigaDana.KnjigaDana = false;
            }

            var novaKnjigaDana= await Context.Knjigas.FirstOrDefaultAsync(x=>x.KnjigaId==id);
            if(novaKnjigaDana == null)
            {
                throw new UserException("Knjiga sa ovim ID-em ne postoji");
            }
            if (novaKnjigaDana.Dostupna == false)
            {
                throw new UserException("Knjiga je nedostupna i ne mozete ju postaviti za knjigu dana");
            }

            novaKnjigaDana.KnjigaDana=true;

            await Context.SaveChangesAsync();
        }
    }
}
