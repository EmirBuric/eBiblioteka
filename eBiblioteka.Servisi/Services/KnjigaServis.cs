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
    public class KnjigaServis : BaseCRUDServis<KnjigaDTO, KnjigaSearchObject, Knjiga, KnjigaInsertRequest, KnjigaUpdateRequest>,IKnjigaServis
    {
        public KnjigaServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Knjiga> AddFilter(KnjigaSearchObject search, IQueryable<Knjiga> query)
        {
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

            return query;
        }

        public override async Task BeforeInsert(KnjigaInsertRequest insert, Knjiga entity, CancellationToken cancellationToken = default)
        {
            if(insert.Kolicina==0)
            {
                entity.Dostupna=false;
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
        }
    }
}
