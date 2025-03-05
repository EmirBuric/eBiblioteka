using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class KnjigaDTO
    {
        public int KnjigaId { get; set; }

        public string Naziv { get; set; } = null!;

        public string? KratkiOpis { get; set; }

        public int? GodinaIzdanja { get; set; }

        public byte[]? Slika { get; set; }

        public int? ZanrId { get; set; }

        public bool? IsDeleted { get; set; }

        public DateTime? VrijemeBrisanja { get; set; }

        public int Kolicina { get; set; }

        public bool? Dostupna { get; set; }

        public bool? KnjigaDana { get; set; }

        public virtual ICollection<KnjigaAutorDTO> KnjigaAutors { get; set; } = new List<KnjigaAutorDTO>();
    }
}
