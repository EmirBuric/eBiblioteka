using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class KnjigaAutorDTO
    {
        public int KnjigaAutorId { get; set; }

        public int? KnjigaId { get; set; }

        public int? AutorId { get; set; }

        public virtual KnjigaDTO? Knjiga { get; set; }
    }
}
