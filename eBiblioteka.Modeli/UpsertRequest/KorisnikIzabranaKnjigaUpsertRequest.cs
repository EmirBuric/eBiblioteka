using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class KorisnikIzabranaKnjigaUpsertRequest
    {

        public int KnjigaId { get; set; }

        public int KorisnikId { get; set; }

        [Required(ErrorMessage = "Ovo polje ne može biti prazno")]
        public DateTime DatumRezervacije { get; set; }

        public DateTime? DatumVracanja { get; set; }

    }
}
