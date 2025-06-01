using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Database;
using eBiblioteka.Servisi.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using RabbitMQ.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Services
{
    public class RezervacijaServis : BaseCRUDServis<RezervacijaDTO, RezervacijaSearchObject, Rezervacija, RezervacijaUpsertRequest, RezervacijaUpsertRequest>, IRezervacijaServis
    {
        private IChannel _channel;
        public RezervacijaServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
            Initialize().GetAwaiter().GetResult();
        }
        private async Task Initialize()
        {
            var factory = new ConnectionFactory
            {
                HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost",
                Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
                UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME"),
                Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD"),
                VirtualHost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/"
            };

            var connection = await factory.CreateConnectionAsync();
            _channel = await connection.CreateChannelAsync();
            await _channel.QueueDeclareAsync(queue: "reservationQueue",
                                 durable: false,
                                 exclusive: false,
                                 autoDelete: false,
                                 arguments: null);
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

            if (search.Odobrena != null)
            {
                query=query.Where(x=>x.Odobrena==search.Odobrena);
            }

            return query;
        }

        public override IQueryable<Rezervacija> AddInclude(IQueryable<Rezervacija> query, RezervacijaSearchObject? search = null)
        {
            query = query.Include("Korisnik");
            query = query.Include("Knjiga");

            return base.AddInclude(query, search);
        }

        public override async Task BeforeInsert(RezervacijaUpsertRequest insert, Rezervacija entity, CancellationToken cancellationToken = default)
        {
            entity.Odobrena=false;
            entity.Pregledana=false;

            var korisnik= await Context.Korisniks.FirstOrDefaultAsync(x=>x.KorisnikId==entity.KorisnikId);

            var korisnikEmail = korisnik.Email;

            if(!string.IsNullOrEmpty(korisnikEmail))
            {
                var message = $"Rezervacija odobrena za {korisnikEmail}";
                var body= Encoding.UTF8.GetBytes(message);     

                await _channel.BasicPublishAsync(exchange: "",
                    routingKey: "reservationQueue",
                    mandatory: false,
                    body: body);
            }


            if (insert.DatumVracanja == null)
                entity.DatumVracanja = insert.DatumRezervacije.AddDays(7);
            else
                entity.DatumVracanja = insert.DatumVracanja.Value;

            await base.BeforeInsert(insert, entity, cancellationToken);
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
