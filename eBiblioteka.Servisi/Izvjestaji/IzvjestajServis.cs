using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Servisi.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Izvjestaji
{
    public class IzvjestajServis:IIzvejstajServis
    {
        private readonly Db180105Context _context;
        private readonly IMapper _mapper;

        public IzvjestajServis(IMapper mapper,Db180105Context context)
        {
            _mapper = mapper;
            _context = context;
        }

        public async Task<KnjigaIzvjestajDTO> GetKnjigaIzvjestaj(int knjigaId, DateTime datumOd, DateTime datumDo)
        {
            var knjiga = await _context.Knjigas
            .Include(k => k.Rezervacijas)
            .Include(k => k.Recenzijas)
            .FirstOrDefaultAsync(k => k.KnjigaId == knjigaId);

            if (knjiga == null) return null;

            var statistika = _mapper.Map<KnjigaIzvjestajDTO>(knjiga);


            var recenzijeUPeriodu = knjiga.Recenzijas
                .Where(r => r.DatumRecenzije >= datumOd && r.DatumRecenzije <= datumDo && r.Ocjena.HasValue)
                .ToList();

            statistika.RecenzijePoOcjeni = recenzijeUPeriodu
                .GroupBy(r => r.Ocjena.Value)
                .ToDictionary(g => g.Key, g => g.Count());


            for (int i = 1; i <= 5; i++)
            {
                if (!statistika.RecenzijePoOcjeni.ContainsKey(i))
                    statistika.RecenzijePoOcjeni[i] = 0;
            }


            var rezervacijeUPeriodu = knjiga.Rezervacijas
                .Where(r => r.DatumRezervacije >= datumOd && r.DatumRezervacije <= datumDo)
                .ToList();

            statistika.RezervacijePoMjesecu = rezervacijeUPeriodu
                .GroupBy(r => $"{r.DatumRezervacije.Year}-{r.DatumRezervacije.Month:D2}")
                .ToDictionary(g => g.Key, g => g.Count());


            var trenutniMjesec = new DateTime(datumOd.Year, datumOd.Month, 1);
            var krajnjiMjesec = new DateTime(datumDo.Year, datumDo.Month, 1);

            while (trenutniMjesec <= krajnjiMjesec)
            {
                var mjesecKey = $"{trenutniMjesec.Year}-{trenutniMjesec.Month:D2}";
                if (!statistika.RezervacijePoMjesecu.ContainsKey(mjesecKey))
                    statistika.RezervacijePoMjesecu[mjesecKey] = 0;

                trenutniMjesec = trenutniMjesec.AddMonths(1);
            }


            statistika.ProsjecnaOcjena = recenzijeUPeriodu.Any() ?
                recenzijeUPeriodu.Average(r => r.Ocjena.Value) : 0;

            return statistika;
        }

        public async Task<ClanarinaIzvjestajDTO> MjesecniIzvjestaj(int mjesec, int godina)
        {
            var tipIzvjestaji = await _context.Clanarinas
                .Where(c => c.DatumUplate.Month == mjesec && c.DatumUplate.Year == godina)
                .Include(c => c.TipClanarine)
                .GroupBy(c => c.TipClanarine.TipClanarineId)
                .Select(g => new TipIzvjestajDTO
                {
                    TipClanarineId = g.Key,
                    BrojPoTipu = g.Count(),
                    ZaradaPoTipu = g.Sum(x => x.TipClanarine.Cijena)
                })
                .ToListAsync();

            var ukupnaZarada = await _context.Clanarinas
                .Where(c => c.DatumUplate.Month == mjesec && c.DatumUplate.Year == godina)
                .SumAsync(c => c.TipClanarine.Cijena);

            return new ClanarinaIzvjestajDTO
            {
                UkupnaZarada = ukupnaZarada,
                TipIzvjestaji = tipIzvjestaji,
            };
        }
    }
}
