using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class KnjigaUpdateRequest
    {
        public string Naziv { get; set; }

        public string? KratkiOpis { get; set; }

        public int? GodinaIzdanja { get; set; }

        //public byte[]? Slika { get; set; }

        public int ZanrId { get; set; }

        public int Kolicina { get; set; }
    }
}
