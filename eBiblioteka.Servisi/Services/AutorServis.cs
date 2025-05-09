﻿using EasyNetQ;
using EasyNetQ.DI;
using EasyNetQ.Serialization.NewtonsoftJson;
using eBiblioteka.Modeli.Messages;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Database;
using eBiblioteka.Servisi.Interfaces;
using MapsterMapper;


namespace eBiblioteka.Servisi.Services
{
    public class AutorServis : BaseCRUDServis<Modeli.DTOs.AutorDTO, AutorSearchObject, Autor, AutorUpsertRequest, AutorUpsertRequest>, IAutorServis
    {
        public AutorServis(Db180105Context context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Autor> AddFilter(AutorSearchObject search, IQueryable<Autor> query)
        {

            var bus = RabbitHutch.CreateBus("host=localhost", serviceRegister => serviceRegister.Register<ISerializer>(_ => new NewtonsoftJsonSerializer()));

            AutoriSearched message= new AutoriSearched { Autori= search };

            bus.PubSub.Publish(message);

            if (!string.IsNullOrEmpty(search?.ImeGTE) || !string.IsNullOrEmpty(search?.PrezimeGTE))
            {
                query = query.Where(x => x.Ime.ToLower().StartsWith(search.ImeGTE)
                || x.Prezime.ToLower().StartsWith(search.PrezimeGTE));
            }
            if (search?.GodinaRodjenjaGTE != null) {
                query = query.Where(x => x.DatumRodjenja.Value.Year > search.GodinaRodjenjaGTE);
            }
            if (search?.GodinaRodjenjaLTE != null)
            {
                query = query.Where(x => x.DatumRodjenja.Value.Year < search.GodinaRodjenjaLTE);
            }
            return query;
        }

    }
}
