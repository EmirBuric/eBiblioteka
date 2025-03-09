using Azure.Core;
using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.Exceptions;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using eBiblioteka.Servisi.Database;
using eBiblioteka.Servisi.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Services
{
    public class KorisnikServis : BaseCRUDServis<KorisniciDTO, KorisnikSearchObject, Korisnik, KorisnikInsertRequest, KorisnikUpdateRequest>, IKorisniciServis
    {
        private readonly ILogger<KorisnikServis> _logger;
        public KorisnikServis(Db180105Context context, IMapper mapper, ILogger<KorisnikServis> logger) : base(context, mapper)
        {
            _logger = logger;
        }

        public override IQueryable<Korisnik> AddFilter(KorisnikSearchObject search, IQueryable<Korisnik> query)
        {
            if (!string.IsNullOrEmpty(search?.ImeGTE))
            {
                query = query.Where(x => x.Ime.ToLower().StartsWith(search.ImeGTE));
            }
            if (!string.IsNullOrEmpty(search?.PrezimeGTE))
            {
                query = query.Where(x => x.Prezime.ToLower().StartsWith(search.PrezimeGTE));
            }
            if (!string.IsNullOrEmpty(search?.Telefon))
            {
                query = query.Where(x => x.Telefon == search.Telefon);
            }
            if (!string.IsNullOrEmpty(search?.Email))
            {
                query = query.Where(x => x.Email == search.Email);
            }
            if (!string.IsNullOrEmpty(search?.KorisnickoIme))
            {
                query = query.Where(x => x.KorisnickoIme == search.KorisnickoIme);
            }
            if (search.IsBanned != null)
            {
                query = query.Where(x => x.IsBanned == search.IsBanned);
            }
            return query;
        }
        public override async Task BeforeInsert(KorisnikInsertRequest insert, Korisnik entity, CancellationToken cancellationToken = default)
        {
            _logger.LogInformation($"Adding user: {entity.KorisnickoIme}");

            if (insert.Lozinka != insert.LozinkaPotvrda)
            {
                throw new UserException("Lozinka i LozinkaPotvrda moraju biti iste");
            }

            entity.LozinkaSalt = GenerateSalt();
            entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, insert.Lozinka);
            base.BeforeInsert(insert, entity);
        }

        public override async Task AfterInsert(KorisnikInsertRequest insert, Korisnik entity, CancellationToken cancellationToken = default)
        {
            if (insert.Uloge != null)
            {
                foreach (var u in insert.Uloge)
                {
                    Context.KorisnikUlogas.Add(new KorisnikUloga
                    {
                        KorisnikId = entity.KorisnikId,
                        UlogaId = u
                    });
                }
                await Context.SaveChangesAsync();
            }
            base.AfterInsert(insert, entity);
        }


        public override async Task BeforeUpdate(KorisnikUpdateRequest update, Korisnik entity, CancellationToken cancellationToken = default)
        {
            base.BeforeUpdate(update, entity);
            if (update.Lozinka != null && update.LozinkaPotvrda != null)
            {
                if (update.Lozinka != update.LozinkaPotvrda)
                {
                    throw new Exception("Lozinka i Potvrda moraju biti iste");
                }
            }
            entity.LozinkaSalt = GenerateSalt();
            entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, update.Lozinka);
        }

        public KorisniciDTO Login(string korisnickoIme, string sifra)
        {
            var entity = Context.Korisniks
                .Include(x => x.KorisnikUlogas)
                .ThenInclude(y => y.Uloga)
                .FirstOrDefault(x => x.KorisnickoIme == korisnickoIme);
            if (entity == null) 
            {
                return null;
            }

            var hash= GenerateHash(entity.LozinkaSalt,sifra);

            if (hash != entity.LozinkaHash)
                return null;

            return Mapper.Map<KorisniciDTO>(entity);
        }


        public static string GenerateSalt()
        {
            var byteArray = RNGCryptoServiceProvider.GetBytes(16);


            return Convert.ToBase64String(byteArray);
        }
        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(inArray);
        }
    }
}
