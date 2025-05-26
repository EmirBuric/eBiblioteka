using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace eBiblioteka.Modeli.UpsertRequest
{
    public class AutorUpsertRequest
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MinLength(2, ErrorMessage = "Ime autora ne može imati manje od dva karaktera")]
        [MaxLength(50, ErrorMessage = "Ime autora ne može imati više od 50 karaktera")]
        public string Ime { get; set; } = null!;
        [Required(AllowEmptyStrings = false, ErrorMessage = "Ovo polje ne može biti prazno")]
        [MinLength(2, ErrorMessage = "Prezime autora ne može imati manje od dva karaktera")]
        [MaxLength(50, ErrorMessage = "Prezime autora ne može imati više od 50 karaktera")]
        public string Prezime { get; set; } = null!;

        public DateTime? DatumRodjenja { get; set; }

        public byte[]? Slika { get; set; }

        public string? Biografija { get; set; }
    }
}
