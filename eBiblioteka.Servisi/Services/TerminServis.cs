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
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace eBiblioteka.Servisi.Services
{
    public class TerminServis : BaseCRUDServis<TerminDTO, TerminSearchObject, Termin, TerminUpsertRequest, TerminUpsertRequest>, ITerminServis
    {
        private readonly ICitaonicaServis _citaonicaServis;
        public TerminServis(Db180105Context context, IMapper mapper, ICitaonicaServis citaonicaServis) : base(context, mapper)
        {
            _citaonicaServis = citaonicaServis;
        }

        public override IQueryable<Termin> AddFilter(TerminSearchObject search, IQueryable<Termin> query)
        {
            if (search.CitaonicaId != null)
            {
                query = query.Where(x => x.CitaonicaId == search.CitaonicaId);
            }

            if (search.KorisnikId != null)
            {
                query = query.Where(x => x.KorisnikId == search.KorisnikId);
            }

            if (search.JeRezervisan != null)
            {
                query = query.Where(x => x.JeRezervisan == search.JeRezervisan);
            }

            if (search.JeProsao != null)
            {
                query = query.Where(x => x.JeProsao == search.JeProsao);
            }

            if (search.DatumGTE != null)
            {
                query = query.Where(x => x.Datum >= search.DatumGTE);
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

            var entity = await query.FirstOrDefaultAsync(x => x.TerminId == id);

            return entity;
        }

        public override Task BeforeInsert(TerminUpsertRequest insert, Termin entity, CancellationToken cancellationToken = default)
        {
            entity.JeRezervisan = false;
            return base.BeforeInsert(insert, entity, cancellationToken);
        }

        public override Task BeforeUpdate(TerminUpsertRequest update, Termin entity, CancellationToken cancellationToken = default)
        {
            entity.JeRezervisan = false;
            return base.BeforeUpdate(update, entity, cancellationToken);
        }

        public async Task GenerisiTermine()
        {
            var danas = DateOnly.FromDateTime(DateTime.Today);
            var sljedecaSedmica = danas.AddDays(7);

            var danStart = new TimeOnly(8, 0);
            var danEnd = new TimeOnly(20, 0);
            var citaonice = (await _citaonicaServis.GetPaged(new CitaonicaSearchObject())).ResultList;

            foreach (var citaonica in citaonice)
            {
                for (var datum = danas; datum < sljedecaSedmica; datum = datum.AddDays(1))
                {
                    for (var pocetak = danStart; pocetak < danEnd; pocetak = pocetak.AddMinutes(30))
                    {
                        var kraj = pocetak.AddMinutes(30);

                        bool postoji = await Context.Termins.AnyAsync(x =>
                            x.Datum == datum &&
                            x.Start == pocetak &&
                            x.Kraj == kraj &&
                            x.CitaonicaId == citaonica.CitaonicaId);

                        if (!postoji)
                        {
                            await Insert(new TerminUpsertRequest
                            {
                                Datum = datum,
                                Start = pocetak,
                                Kraj = kraj,
                                CitaonicaId = citaonica.CitaonicaId
                            });
                        }
                    }
                }
            }

        }

        public async Task Otkazi(int terminId)
        {
            var termin = await Context.Termins.FirstOrDefaultAsync(x => x.TerminId == terminId);
            if (termin == null)
                throw new UserException("Ne postoji termin sa poslanim ID-em");
            termin.KorisnikId=null;
            termin.JeRezervisan=false;

            await Context.SaveChangesAsync();
        }

        public async Task ProvjeriJeLiProsao()
        {
            var danas = DateOnly.FromDateTime(DateTime.Today);
            var sad = TimeOnly.FromDateTime(DateTime.Now);

            var terminiZaOznaciti = await Context.Termins
                .Where(t => t.Datum <= danas && t.Start < sad && !t.JeProsao)
                .ToListAsync();

            foreach (var termin in terminiZaOznaciti)
            {
                termin.JeProsao = true;
            }

            await Context.SaveChangesAsync();
        }

        public async Task Rezervisi(RezervisiTerminRequest req)
        {
            var termin = await Context.Termins.FirstOrDefaultAsync(x => x.TerminId == req.TerminId);
            if (termin == null) 
            {
                throw new UserException("Ne postoji termin sa poslanim ID-em");
            }

            termin.KorisnikId = req.KorisnikId;
            termin.JeRezervisan=true;

            await Context.SaveChangesAsync();
        }
    }
}
