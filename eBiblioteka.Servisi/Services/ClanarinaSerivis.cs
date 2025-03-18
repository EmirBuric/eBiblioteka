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
    public class ClanarinaSerivis : BaseCRUDServis<ClanarinaDTO, ClanarinaSearchObject, Clanarina, ClanarinaUpsertRequest, ClanarinaUpsertRequest>, IClanarinaServis
    {
        public ClanarinaSerivis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Clanarina> AddFilter(ClanarinaSearchObject search, IQueryable<Clanarina> query)
        {
            if(search.TipClanarineId!=null)
            {
                query=query.Where(x=>x.TipClanarineId==search.TipClanarineId);
            }

            if(!string.IsNullOrEmpty(search.StatusClanarineGTE))
            {
                query = query.Where(x => x.StatusClanarine.ToLower().StartsWith(search.StatusClanarineGTE));
            }

            if (search.DatumUplateGTE != null) 
            {
                query = query.Where(x => x.DatumUplate >= search.DatumUplateGTE);
            }

            if (search.DatumUplateLTE != null)
            {
                query = query.Where(x => x.DatumUplate <= search.DatumUplateLTE);
            }

            if (search.DatumIstekaGTE != null)
            {
                query = query.Where(x => x.DatumIsteka >= search.DatumIstekaGTE);
            }

            if (search.DatumIstekaLTE != null)
            {
                query = query.Where(x => x.DatumIsteka <= search.DatumIstekaLTE);
            }

            return query;
        }

        public override IQueryable<Clanarina> AddInclude(IQueryable<Clanarina> query, ClanarinaSearchObject? search = null)
        {
            query = query.Include("Korisnik");

            return base.AddInclude(query, search);
        }

        public override async Task<Clanarina> AddIncludeId(IQueryable<Clanarina> query, int id)
        {
            query = query.Include("Korisnik");

            var entity = await query.FirstOrDefaultAsync(x => x.ClanarinaId == id);

            return entity;
        }

        public override Task BeforeInsert(ClanarinaUpsertRequest insert, Clanarina entity, CancellationToken cancellationToken = default)
        {
            switch (insert.TipClanarineId)
            {
                case 1:
                    entity.DatumIsteka = insert.DatumUplate.AddMonths(1);
                    break;
                case 2:
                    entity.DatumIsteka = insert.DatumUplate.AddMonths(3);
                    break;
                case 3:
                    entity.DatumIsteka = insert.DatumUplate.AddMonths(6);
                    break;
                case 4:
                    entity.DatumIsteka = insert.DatumUplate.AddMonths(12);
                    break;
            }

            return base.BeforeInsert(insert, entity, cancellationToken);
        }

        public override Task BeforeUpdate(ClanarinaUpsertRequest update, Clanarina entity, CancellationToken cancellationToken = default)
        {
            switch (update.TipClanarineId)
            {
                case 1:
                    entity.DatumIsteka = update.DatumUplate.AddMonths(1);
                    break;
                case 2:
                    entity.DatumIsteka = update.DatumUplate.AddMonths(3);
                    break;
                case 3:
                    entity.DatumIsteka = update.DatumUplate.AddMonths(6);
                    break;
                case 4:
                    entity.DatumIsteka = update.DatumUplate.AddMonths(12);
                    break;
            }

            return base.BeforeUpdate(update, entity, cancellationToken);
        }
    }
}
