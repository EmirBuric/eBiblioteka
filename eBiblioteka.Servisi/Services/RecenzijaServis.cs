﻿using eBiblioteka.Modeli.DTOs;
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
    public class RecenzijaServis : BaseCRUDServis<RecenzijaDTO, RecenzijaSearchObject, Recenzija, RecenzijaUpsertRequest, RecenzijaUpsertRequest>,IRecenzijaServis
    {
        public RecenzijaServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Recenzija> AddFilter(RecenzijaSearchObject search, IQueryable<Recenzija> query)
        {
            if (search.KorisnikId != null)
            {
                query = query.Where(x => x.KorisnikId == search.KorisnikId);
            }

            if (search.KnjigaId != null)
            {
                query = query.Where(x => x.KnjigaId == search.KnjigaId);
            }

            if(search.OcjenaGTE != null)
            {
                query=query.Where(x=>x.Ocjena>=search.OcjenaGTE);
            }

            if (search.OcjenaLTE != null)
            {
                query = query.Where(x => x.Ocjena <= search.OcjenaLTE);
            }

            if (!string.IsNullOrEmpty(search.NazivGTE))
            {
                query = query.Include(x => x.Knjiga).Where(x => x.Knjiga.Naziv.ToLower().StartsWith(search.NazivGTE));
            }

            if (!string.IsNullOrEmpty(search.ImePrezimeGTE))
            {
                query = query.Include(x => x.Korisnik).Where(x => (x.Korisnik.Ime + " " + x.Korisnik.Prezime).ToLower().StartsWith(search.ImePrezimeGTE));
            }
            return base.AddFilter(search, query);
        }

        public override IQueryable<Recenzija> AddInclude(IQueryable<Recenzija> query, RecenzijaSearchObject? search = null)
        {
            query = query.Include("Korisnik");
            query = query.Include("Knjiga");

            return base.AddInclude(query, search);
        }

        public override Task BeforeInsert(RecenzijaUpsertRequest insert, Recenzija entity, CancellationToken cancellationToken = default)
        {
            entity.Odobrena=false;

            entity.DatumRecenzije=DateTime.Now;

            return base.BeforeInsert(insert, entity, cancellationToken);
        }

        public override Task BeforeUpdate(RecenzijaUpsertRequest update, Recenzija entity, CancellationToken cancellationToken = default)
        {
            entity.Odobrena=false;
            return base.BeforeUpdate(update, entity, cancellationToken);
        }

        public override async Task<Recenzija> AddIncludeId(IQueryable<Recenzija> query, int id)
        {
            query = query.Include("Korisnik");
            query = query.Include("Knjiga");

            var entity= await query.FirstOrDefaultAsync(x=>x.RecenzijaId==id);

            return entity;
        }

    }
}
