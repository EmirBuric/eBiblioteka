using eBiblioteka.Modeli.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Izvjestaji
{
    public interface IIzvejstajServis
    {
        public Task<KnjigaIzvjestajDTO> GetKnjigaIzvjestaj(int knjigaId, DateTime datumOd, DateTime datumDo);
    }
}
