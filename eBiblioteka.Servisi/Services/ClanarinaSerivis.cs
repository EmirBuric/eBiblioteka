using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.Exceptions;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Database;
using eBiblioteka.Servisi.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Services
{
    public class ClanarinaSerivis : BaseCRUDServis<ClanarinaDTO, ClanarinaSearchObject, Clanarina, ClanarinaUpsertRequest, ClanarinaUpsertRequest>, IClanarinaServis
    {
        private readonly ITipClanarineServis _tipClanarineServis;

        public ClanarinaSerivis(Db180105Context context, IMapper mapper, ITipClanarineServis tipClanarineServis) : base(context, mapper)
        {
            _tipClanarineServis = tipClanarineServis;
        }

        public override IQueryable<Clanarina> AddFilter(ClanarinaSearchObject search, IQueryable<Clanarina> query)
        {
            if (search.TipClanarineId != null)
            {
                query = query.Where(x => x.TipClanarineId == search.TipClanarineId);
            }

            if (search.StatusClanarine != null)
            {
                query = query.Where(x => x.StatusClanarine == search.StatusClanarine);
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

        public override async Task BeforeInsert(ClanarinaUpsertRequest insert, Clanarina entity, CancellationToken cancellationToken = default)
        {
            var tip = await _tipClanarineServis.GetById(insert.TipClanarineId);
            if (tip == null)
            {
                throw new UserException("Nepostojeci Tip Clanarine");
            }
            entity.DatumIsteka = insert.DatumUplate.AddMonths(tip.VrijemeTrajanja);

            await base.BeforeInsert(insert, entity, cancellationToken);
        }

        public override async Task BeforeUpdate(ClanarinaUpsertRequest update, Clanarina entity, CancellationToken cancellationToken = default)
        {
            var tip = await _tipClanarineServis.GetById(update.TipClanarineId);

            if (tip == null)
            {
                throw new UserException("Nepostojeci Tip Clanarine");
            }

            var vrijeme = entity.DatumIsteka.Month - update.DatumUplate.Month;

            if (vrijeme > tip.VrijemeTrajanja)
            {
                throw new UserException("Novi period je kreci od trenutnog");
            }

            entity.DatumIsteka = update.DatumUplate.AddMonths(tip.VrijemeTrajanja);

            await base.BeforeUpdate(update, entity, cancellationToken);
        }

        public async Task<ClanarinaDTO> GetClanarinaByKorisnikId(int korisnikId)
        {
            var clanarina = await Context.Clanarinas.FirstOrDefaultAsync(x => x.KorisnikId == korisnikId);
            if (clanarina == null)
                return null;

            return Mapper.Map<ClanarinaDTO>(clanarina);
        }

        public async Task ProvjeriValidnostClanarine()
        {
            var danas = DateTime.Now.Date;

            var clanarineZaAzurirati = await Context.Clanarinas
                .Where(c => c.DatumIsteka.Date <= danas && c.StatusClanarine)
                .ToListAsync();

            foreach (var clanarina in clanarineZaAzurirati)
            {
                clanarina.StatusClanarine = false;
            }

            if (clanarineZaAzurirati.Any())
            {
                await Context.SaveChangesAsync();
            }
        }
    }
}
