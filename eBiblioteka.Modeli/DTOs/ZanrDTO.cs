using System;
using System.Collections.Generic;
using System.Text;

namespace eBiblioteka.Modeli.DTOs
{
    public class ZanrDTO
    {
        public int ZanrId { get; set; }

        public string Naziv { get; set; } = null!;

        public virtual ICollection<KnjigaDTO> Knjigas { get; set; } = new List<KnjigaDTO>();
    }
}
