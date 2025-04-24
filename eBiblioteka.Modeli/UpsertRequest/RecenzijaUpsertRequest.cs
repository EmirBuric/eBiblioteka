using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class RecenzijaUpsertRequest
    {
        [Required(ErrorMessage = "Ovo polje ne može biti prazno")]
        [Range(1, 5, ErrorMessage = "Ocjena može biti od 1 do 5")]
        public int Ocjena { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MaxLength(500, ErrorMessage = "Komentar ne može imati više od 500 karaktera")]
        public string Opis { get; set; }

        public int KnjigaId { get; set; }

        public int KorisnikId { get; set; }
    }
}
