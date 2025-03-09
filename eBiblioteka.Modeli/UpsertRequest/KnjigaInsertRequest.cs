using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class KnjigaInsertRequest
    {
        public string Naziv { get; set; } 

        public string? KratkiOpis { get; set; }

        public int GodinaIzdanja { get; set; }

        //public byte[]? Slika { get; set; }

        public int? ZanrId { get; set; }

        public int Kolicina { get; set; }
       
        public List<int> Autori { get; set; }
    }
}
