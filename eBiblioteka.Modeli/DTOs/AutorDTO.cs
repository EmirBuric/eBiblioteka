using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class AutorDTO
    {
        public int AutorId { get; set; }

        public string Ime { get; set; } = null!;

        public string Prezime { get; set; } = null!;

        public DateTime? DatumRodjenja { get; set; }

        public string? Biografija { get; set; }

        public byte[]? Slika { get; set; }

        public ICollection<KnjigaAutorDTO>? KnjigaAutors { get; set; }
    }
}
